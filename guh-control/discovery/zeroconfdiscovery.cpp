#include "zeroconfdiscovery.h"

#include <QUuid>


ZeroconfDiscovery::ZeroconfDiscovery(QObject *parent) : QObject(parent)
{
    m_discoveryModel = new DiscoveryModel(this);

#ifdef WITH_AVAHI
    m_serviceBrowser = new QtAvahiServiceBrowser(this);
    connect(m_serviceBrowser, &QtAvahiServiceBrowser::serviceEntryAdded, this, &ZeroconfDiscovery::serviceEntryAdded);
    m_serviceBrowser->enable();
#endif
}

bool ZeroconfDiscovery::available() const
{
#ifdef WITH_AVAHI
    return true;
#else
    return false;
#endif
}

bool ZeroconfDiscovery::discovering() const
{
    return true;
}

DiscoveryModel *ZeroconfDiscovery::discoveryModel() const
{
    return m_discoveryModel;
}
#ifdef WITH_AVAHI
void ZeroconfDiscovery::serviceEntryAdded(const AvahiServiceEntry &entry)
{
    if (!entry.name().startsWith("guhIO") || entry.serviceType() != "_jsonrpc._tcp") {
        return;
    }
    qDebug() << "avahi service entry added" << entry.name() << entry.hostAddress() << entry.port() << entry.txt() << entry.serviceType();

    QString uuid;
    bool sslEnabled = false;
    foreach (const QString &txt, entry.txt()) {
        QPair<QString, QString> txtRecord = qMakePair<QString, QString>(txt.split("=").first(), txt.split("=").at(1));
        if (!sslEnabled && txtRecord.first == "sslEnabled") {
            sslEnabled = (txtRecord.second == "true");
        }
        if (txtRecord.first == "uuid") {
            uuid = txtRecord.second;
        }
    }

    DiscoveryDevice dev = m_discoveryModel->find(entry.hostAddress());
    if (dev.uuid() == uuid && dev.guhRpcUrl().startsWith("guhs") && !sslEnabled) {
        // We already have this host and with a more secure configuration... skip this one...
        return;
    }
    dev.setUuid(uuid);
    dev.setHostAddress(entry.hostAddress());
    dev.setPort(entry.port());
    dev.setFriendlyName(entry.hostName());
    dev.setGuhRpcUrl(QString("%1://%2:%3").arg(sslEnabled ? "guhs" : "guh").arg(entry.hostAddress().toString()).arg(entry.port()));
    m_discoveryModel->addDevice(dev);

//    DiscoveryDevice *dev = new DiscoveryDevice();
//    dev->setFriendlyName(entry.hostName());
}
#endif