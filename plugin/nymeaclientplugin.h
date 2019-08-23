#ifndef NYMEACLIENTPLUGIN_H
#define NYMEACLIENTPLUGIN_H

#include <QQmlExtensionPlugin>

class NymeaClientPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)

public:
    void registerTypes(const char *uri) override;
};

#endif // NYMEACLIENTPLUGIN_H
