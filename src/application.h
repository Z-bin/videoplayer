#ifndef APPLICATION_H
#define APPLICATION_H

#include <QTime>
#include <QObject>
#include <QAction>
#include <KActionCollection>
#include <KSharedConfig>

class HarunaSettings;
class KActionCollection;
class KConfigDialog;
class QAction;

class Application : public QObject
{
    Q_OBJECT
public:
    explicit Application(QObject *parent = nullptr);
    ~Application() = default;

signals:
    void settingsChanged();

public slots:
    static QString formatTime(const double time);
    void configureShortcust();  // 配置快捷键
    QString argument(int key);
    void addArgument(int key, QString value);
    QUrl getPathFromArg(QString arg);

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
