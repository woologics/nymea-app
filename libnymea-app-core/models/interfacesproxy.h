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

#ifndef INTERFACESPROXY_H
#define INTERFACESPROXY_H

#include <QSortFilterProxyModel>

class Devices;
class DevicesProxy;
class Interface;
class Interfaces;

class InterfacesProxy: public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

    Q_PROPERTY(QStringList shownInterfaces READ shownInterfaces WRITE setShownInterfaces NOTIFY shownInterfacesChanged)
    Q_PROPERTY(Devices* devicesFilter READ devicesFilter WRITE setDevicesFilter NOTIFY devicesFilterChanged)
    Q_PROPERTY(DevicesProxy* devicesProxyFilter READ devicesProxyFilter WRITE setDevicesProxyFilter NOTIFY devicesProxyFilterChanged)
    Q_PROPERTY(bool showEvents READ showEvents WRITE setShowEvents NOTIFY showEventsChanged)
    Q_PROPERTY(bool showActions READ showActions WRITE setShowActions NOTIFY showActionsChanged)
    Q_PROPERTY(bool showStates READ showStates WRITE setShowStates NOTIFY showStatesChanged)

public:
    InterfacesProxy(QObject *parent = nullptr);

    QStringList shownInterfaces() const { return m_shownInterfaces; }
    void setShownInterfaces(const QStringList &shownInterfaces) { m_shownInterfaces = shownInterfaces; emit shownInterfacesChanged(); invalidateFilter(); }

    Devices* devicesFilter() const { return m_devicesFilter; }
    void setDevicesFilter(Devices *devices) { m_devicesFilter = devices; emit devicesFilterChanged(); invalidateFilter(); }

    DevicesProxy* devicesProxyFilter() const { return m_devicesProxyFilter; }
    void setDevicesProxyFilter(DevicesProxy *devicesProxy) { m_devicesProxyFilter = devicesProxy; emit devicesProxyFilterChanged(); invalidateFilter(); }

    bool showEvents() const;
    void setShowEvents(bool showEvents);

    bool showActions() const;
    void setShowActions(bool showActions);

    bool showStates() const;
    void setShowStates(bool showStates);

    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

    Q_INVOKABLE Interface* get(int index) const;

signals:
    void shownInterfacesChanged();
    void devicesFilterChanged();
    void devicesProxyFilterChanged();
    void showEventsChanged();
    void showActionsChanged();
    void showStatesChanged();

    void countChanged();

private:
    Interfaces *m_interfaces = nullptr;
    QStringList m_shownInterfaces;
    Devices* m_devicesFilter = nullptr;
    DevicesProxy* m_devicesProxyFilter = nullptr;
    bool m_showEvents = false;
    bool m_showActions = false;
    bool m_showStates = false;
};

#endif // INTERFACESPROXY_H
