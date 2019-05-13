#ifndef CLOUDTRANSPORT_H
#define CLOUDTRANSPORT_H

#include "nymeatransportinterface.h"

#include <QObject>
#include <QUrl>

class AWSClient;
namespace remoteproxyclient {
class RemoteProxyConnection;
}

class CloudTransportFactory: public NymeaTransportInterfaceFactory
{
public:
    CloudTransportFactory();
    NymeaTransportInterface* createTransport(QObject *parent = nullptr) const override;
    QStringList supportedSchemes() const override;
};

class CloudTransport : public NymeaTransportInterface
{
    Q_OBJECT
public:
    explicit CloudTransport(AWSClient *awsClient, QObject *parent = nullptr);

    bool connect(const QUrl &url) override;
    QUrl url() const override;
    void disconnect() override;
    ConnectionState connectionState() const override;
    void sendData(const QByteArray &data) override;

#ifndef QT_NO_SSL
    void ignoreSslErrors(const QList<QSslError> &errors) override;
#endif
private:
    QUrl m_url;
    AWSClient *m_awsClient = nullptr;
    remoteproxyclient::RemoteProxyConnection *m_remoteproxyConnection = nullptr;
    QDateTime m_timestamp;
};

#endif // CLOUDTRANSPORT_H
