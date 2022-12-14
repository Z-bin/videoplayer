#ifndef APPLICATION_H
#define APPLICATION_H

#include <QObject>
#include <QAction>
#include <KActionCollection>
#include <KSharedConfig>

#include "ui_settings.h"

class HarunaSettings;
class KActionCollection;
class KConfigDialog;
class QAction;

class SettingsWidget : public QWidget, public Ui::SettingsWidget
{
    Q_OBJECT
public:
    explicit SettingsWidget(QWidget *parent) : QWidget(parent){
        setupUi(this);
    }
};

class Application : public QObject
{
    Q_OBJECT
public:
    explicit Application(QObject *parent = nullptr);
    ~Application() = default;

signals:
    void settingsChanged();

public slots:
    void configureShortcust();  // 配置快捷键
    QString argument(int key);
    void addArgument(int key, QString value);
    QString getPathFromArg(QString arg);

    void hideCursor();
    void showCursor();
    QAction *action(const QString &name);
    QString iconName(const QIcon &icon);

private:
    void setupActions(const QString &actionName);
    KActionCollection m_collection;
    KSharedConfig::Ptr m_config;
    KConfigGroup *m_shortcuts;
    QMap<int, QString> args;
};



#endif // APPLICATION_H
