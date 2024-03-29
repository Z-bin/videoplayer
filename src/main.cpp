#include "_debug.h"
#include "application.h"
#include "lockmanager.h"
#include "mpvobject.h"
#include "tracksmodel.h"
#include "subtitlesfoldersmodel.h"
#include "playlist/playlist.h"
#include "playlist/playlistitem.h"
#include "playlist/playlistmodel.h"
#include "settings.h"
#include "worker.h"

#include <QGuiApplication>
#include <QCommandLineParser>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QQmlContext>
#include <QQuickItem>
#include <QThread>
#include <QApplication>

#include <klocalizedstring.h>
#include <memory>

int main(int argc, char *argv[])
{
    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);
    app.setOrganizationName("georgefb");
    app.setOrganizationDomain("georgefb.com");
    app.setWindowIcon(QIcon::fromTheme("folder-videos-symbolic"));

    QCommandLineParser parser;
    parser.addPositionalArgument(QStringLiteral("file"), i18n("Document to open"));
    parser.process(app);

    // Qt sets the locale in the QGuiApplication constructor, but libmpv
    // requires the LC_NUMERIC category to be set to "C", so change it back.
    std::setlocale(LC_NUMERIC, "C");

    qmlRegisterType<MpvObject>("mpv", 1, 0, "MpvObject");
    // 注册C++类型提供给QML
    qmlRegisterInterface<QAction>("QAction");
    qmlRegisterInterface<TracksModel>("TracksModel");

    QQuickStyle::setStyle(QStringLiteral("org.kde.desktop"));
    QQuickStyle::setFallbackStyle(QStringLiteral("Fusion"));

    std::unique_ptr<Application> myApp = std::make_unique<Application>();
    std::unique_ptr<LockManager> lockManager = std::make_unique<LockManager>();
    std::unique_ptr<SubtitlesFoldersModel> subsFoldersModel = std::make_unique<SubtitlesFoldersModel>();
    std::unique_ptr<Settings> settings = std::make_unique<Settings>();

    for (auto i = 0; i < parser.positionalArguments().size(); ++i)  {
        myApp->addArgument(i, parser.positionalArguments().at(i));
    }

    // 放入线程中防止获取时间阻塞
    auto worker = Worker::instance();
    auto thread = new QThread();
    worker->moveToThread(thread);
    QObject::connect(thread, &QThread::finished,
                     worker, &Worker::deleteLater);
    QObject::connect(thread, &QThread::finished,
                     thread, &QThread::deleteLater);
    thread->start();

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    VideoList *videoList = new VideoList();
    engine.rootContext()->setContextProperty("videoList", videoList);
    qmlRegisterUncreatableType<VideoList>("VideoPlayList", 1, 0, "VideoList",
                                          QStringLiteral("VideoList should not be created in QML"));
    VideoListModel videoListModel(videoList);
    engine.rootContext()->setContextProperty("videoListModel", &videoListModel);
    qmlRegisterUncreatableType<VideoListModel>("VideoPlayList", 1, 0, "VideoListModel",
                                               QStringLiteral("VideoListModel should not be created in QML"));

    engine.rootContext()->setContextProperty(QStringLiteral("app"), myApp.release());
    qmlRegisterUncreatableType<Application>("Application", 1, 0, "Application",
                                             QStringLiteral("Application should not be created in QML"));

    engine.rootContext()->setContextProperty(QStringLiteral("lockManager"), lockManager.release());
    qmlRegisterUncreatableType<LockManager>("LockManager", 1, 0, "LockManager",
                                            QStringLiteral("LockManager should not be created in QML"));

    engine.rootContext()->setContextProperty(QStringLiteral("subsFoldersModel"), subsFoldersModel.release());
    engine.rootContext()->setContextProperty(QStringLiteral("settings"), settings.release());
    engine.load(url);

    app.exec();
}
