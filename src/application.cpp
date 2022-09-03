#include "application.h"
#include "_debug.h"

#include <QApplication>
#include <QAction>
#include <QCoreApplication>
#include <QStandardPaths>
#include <KConfig>
#include <KConfigGroup>
#include <KLocalizedString>
#include <KShortcutsDialog>

Application::Application(QObject *parent)
    : m_collection(parent)
{
    Q_UNUSED(parent)

    m_config = KSharedConfig::openConfig("georgefb/haruna.conf");
    m_shortcuts = new KConfigGroup(m_config, "Shortcuts");
}


QAction *Application::action(const QString &name)
{
    auto resultAction = m_collection.action(name);
    if (!resultAction) {
        setupActions(name);
        resultAction = m_collection.action(name);
    }

    return resultAction;
}

QString Application::iconName(const QIcon &icon)
{
    return icon.name();
}

void Application::setupActions(const QString &actionName)
{
    if (actionName == QStringLiteral("file_quit")) {
        auto action = KStandardAction::quit(QCoreApplication::instance(), &QCoreApplication::quit, &m_collection);
        m_collection.addAction(actionName, action);
    }

    DEBUG << actionName;
    m_collection.readSettings(m_shortcuts);
}
