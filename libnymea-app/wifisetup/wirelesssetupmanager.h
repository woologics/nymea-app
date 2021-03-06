/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef WIRELESSSETUPMANAGER_H
#define WIRELESSSETUPMANAGER_H

#include <QObject>
#include <QBluetoothDeviceInfo>

#include "bluetoothdevice.h"

class WirelessAccessPoint;
class WirelessAccessPoints;
class WirelessAccessPointsProxy;

class WirelessSetupManager : public BluetoothDevice
{
    Q_OBJECT
    Q_PROPERTY(bool working READ working NOTIFY workingChanged)
    Q_PROPERTY(bool initialized READ initialized NOTIFY initializedChanged)

    Q_PROPERTY(WirelessAccessPoints *accessPoints READ accessPoints CONSTANT)
    Q_PROPERTY(WirelessAccessPoint *currentConnection READ currentConnection NOTIFY currentConnectionChanged)

    Q_PROPERTY(QString modelNumber READ modelNumber NOTIFY modelNumberChanged)
    Q_PROPERTY(QString manufacturer READ manufacturer NOTIFY manufacturerChanged)
    Q_PROPERTY(QString softwareRevision READ softwareRevision NOTIFY softwareRevisionChanged)
    Q_PROPERTY(QString firmwareRevision READ firmwareRevision NOTIFY firmwareRevisionChanged)
    Q_PROPERTY(QString hardwareRevision READ hardwareRevision NOTIFY hardwareRevisionChanged)

    Q_PROPERTY(NetworkStatus networkStatus READ networkStatus NOTIFY networkStatusChanged)
    Q_PROPERTY(WirelessStatus wirelessStatus READ wirelessStatus NOTIFY wirelessStatusChanged)
    Q_PROPERTY(bool networkingEnabled READ networkingEnabled NOTIFY networkingEnabledChanged)
    Q_PROPERTY(bool wirelessEnabled READ wirelessEnabled NOTIFY wirelessEnabledChanged)

public:

    enum WirelessServiceCommand {
        WirelessServiceCommandInvalid = -1,
        WirelessServiceCommandGetNetworks           = 0x00,
        WirelessServiceCommandConnect               = 0x01,
        WirelessServiceCommandConnectHidden         = 0x02,
        WirelessServiceCommandDisconnect            = 0x03,
        WirelessServiceCommandScan                  = 0x04,
        WirelessServiceCommandGetCurrentConnection  = 0x05
    };
    Q_ENUM(WirelessServiceCommand)

    enum WirelessServiceResponse {
        WirelessServiceResponseSuccess                     = 0x00,
        WirelessServiceResponseIvalidCommand               = 0x01,
        WirelessServiceResponseIvalidParameters            = 0x02,
        WirelessServiceResponseNetworkManagerNotAvailable  = 0x03,
        WirelessServiceResponseWirelessNotAvailable        = 0x04,
        WirelessServiceResponseWirelessNotEnabled          = 0x05,
        WirelessServiceResponseNetworkingNotEnabled        = 0x06,
        WirelessServiceResponseUnknownError                = 0x07
    };
    Q_ENUM(WirelessServiceResponse)

    enum NetworkServiceCommand {
        NetworkServiceCommandInvalid = -1,
        NetworkServiceCommandEnableNetworking   = 0x00,
        NetworkServiceCommandDisableNetworking  = 0x01,
        NetworkServiceCommandEnableWireless     = 0x02,
        NetworkServiceCommandDisableWireless    = 0x03
    };
    Q_ENUM(NetworkServiceCommand)

    enum NetworkServiceResponse {
        NetworkServiceResponseSuccess                      = 0x00,
        NetworkServiceResponseIvalidValue                  = 0x01,
        NetworkServiceResponseNetworkManagerNotAvailable   = 0x02,
        NetworkServiceResponseWirelessNotAvailable         = 0x03,
        NetworkServiceResponseUnknownError                 = 0x04,
    };
    Q_ENUM(NetworkServiceResponse)

    enum SystemServiceCommand {
        SystemServiceCommandInvalid = -1,
        SystemServiceCommandPushAuthentication = 0x00
    };
    Q_ENUM(SystemServiceCommand)

    enum SystemServiceResponse {
        SystemServiceResponseSuccess                = 0x00,
        SystemServiceResponseUnknownError           = 0x01,
        SystemServiceResponseInvalidCommand         = 0x02,
        SystemServiceResponseInvalidValue           = 0x03,
        SystemServiceResponsePushServiceUnavailable = 0x04,
    };
    Q_ENUM(SystemServiceResponse)

    enum NetworkStatus {
        NetworkStatusUnknown = 0x00,
        NetworkStatusAsleep = 0x01,
        NetworkStatusDisconnected = 0x02,
        NetworkStatusDisconnecting = 0x03,
        NetworkStatusConnecting = 0x04,
        NetworkStatusLocal = 0x05,
        NetworkStatusConnectedSite = 0x06,
        NetworkStatusGlobal = 0x07
    };
    Q_ENUM(NetworkStatus)

    enum WirelessStatus {
        WirelessStatusUnknown = 0x00,
        WirelessStatusUnmanaged = 0x01,
        WirelessStatusUnavailable = 0x02,
        WirelessStatusDisconnected = 0x03,
        WirelessStatusPrepare = 0x04,
        WirelessStatusConfig = 0x05,
        WirelessStatusNeedAuth = 0x06,
        WirelessStatusIpConfig = 0x07,
        WirelessStatusIpCheck = 0x08,
        WirelessStatusSecondaries = 0x09,
        WirelessStatusActivated = 0x0A,
        WirelessStatusDeactivating = 0x0B,
        WirelessStatusFailed = 0x0C
    };
    Q_ENUM(WirelessStatus)

    explicit WirelessSetupManager(const QBluetoothDeviceInfo &deviceInfo, QObject *parent = nullptr);

    QString modelNumber() const;
    QString manufacturer() const;
    QString softwareRevision() const;
    QString firmwareRevision() const;
    QString hardwareRevision() const;

    bool initialized() const;
    bool working() const;

    NetworkStatus networkStatus() const;
    WirelessSetupManager::WirelessStatus wirelessStatus() const;

    bool networkingEnabled() const;
    bool wirelessEnabled() const;

    WirelessAccessPoints *accessPoints() const;
    WirelessAccessPoint *currentConnection() const;

    void reloadData();

    // Wireless commands
    Q_INVOKABLE void loadNetworks();
    Q_INVOKABLE void loadCurrentConnection();
    Q_INVOKABLE void performWifiScan();
    Q_INVOKABLE void enableNetworking(bool enable);
    Q_INVOKABLE void enableWireless(bool enable);
    Q_INVOKABLE void connectWirelessNetwork(const QString &ssid, const QString &password = QString());
    Q_INVOKABLE void disconnectWirelessNetwork();
    Q_INVOKABLE void pressPushButton();

signals:
    void modelNumberChanged();
    void manufacturerChanged();
    void softwareRevisionChanged();
    void firmwareRevisionChanged();
    void hardwareRevisionChanged();

    void initializedChanged();
    void workingChanged();

    void networkStatusChanged();
    void wirelessStatusChanged();
    void networkingEnabledChanged();
    void wirelessEnabledChanged();

    void currentConnectionChanged();

    void errorOccurred(const QString &errorMessage);

private slots:
    void onConnectedChanged();
    void onServiceDiscoveryFinished();

    void onDeviceInformationStateChanged(const QLowEnergyService::ServiceState &state);
    void onDeviceInformationCharacteristicChanged(const QLowEnergyCharacteristic &characteristic, const QByteArray &value);
    void onDeviceInformationReadFinished(const QLowEnergyCharacteristic &characteristic, const QByteArray &value);

    void onNetworkServiceStateChanged(const QLowEnergyService::ServiceState &state);
    void onNetworkServiceCharacteristicChanged(const QLowEnergyCharacteristic &characteristic, const QByteArray &value);
    void onNetworkServiceReadFinished(const QLowEnergyCharacteristic &characteristic, const QByteArray &value);

    void onWifiServiceStateChanged(const QLowEnergyService::ServiceState &state);
    void onWifiServiceCharacteristicChanged(const QLowEnergyCharacteristic &characteristic, const QByteArray &value);
    void onWifiServiceReadFinished(const QLowEnergyCharacteristic &characteristic, const QByteArray &value);

    void onSystemServiceStateChanged(const QLowEnergyService::ServiceState &state);
    void onSystemServiceCharacteristicChanged(const QLowEnergyCharacteristic &characteristic, const QByteArray &value);
    void onSystemServiceReadFinished(const QLowEnergyCharacteristic &characteristic, const QByteArray &value);

private:
    QLowEnergyService *m_deviceInformationService = nullptr;
    QLowEnergyService *m_netwokService = nullptr;
    QLowEnergyService *m_wifiService = nullptr;
    QLowEnergyService *m_systemService = nullptr;

    WirelessAccessPoints *m_accessPoints = nullptr;
    WirelessAccessPoint *m_currentConnection = nullptr;

    QString m_modelNumber;
    QString m_manufacturer;
    QString m_softwareRevision;
    QString m_firmwareRevision;
    QString m_hardwareRevision;

    bool m_networkingEnabled = false;
    bool m_wirelessEnabled = false;

    bool m_working = false;
    bool m_initialized = false;

    NetworkStatus m_networkStatus = NetworkStatusUnknown;
    WirelessStatus m_wirelessStatus = WirelessStatusUnknown;

    bool m_readingResponse = false;
    QByteArray m_inputDataStream;

    QString m_ssid;
    QString m_password;

    QVariantList m_accessPointsVariantList;

    void checkInitialized();

    // Private set methods for read only properties
    void setModelNumber(const QString &modelNumber);
    void setManufacturer(const QString &manufacturer);
    void setSoftwareRevision(const QString &softwareRevision);
    void setFirmwareRevision(const QString &firmwareRevision);
    void setHardwareRevision(const QString &hardwareRevision);

    void setNetworkStatus(int networkStatus);
    void setWirelessStatus(int wirelessStatus);
    void setNetworkingEnabled(bool networkingEnabled);
    void setWirelessEnabled(bool wirelessEnabled);

    // Data methods
    void streamData(const QVariantMap &request);
    void processNetworkResponse(const QVariantMap &response);
    void processWifiResponse(const QVariantMap &response);
    void processSystemResponse(const QVariantMap &response);

};

#endif // WIRELESSSETUPMANAGER_H
