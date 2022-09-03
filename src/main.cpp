#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QQmlContext>
#include <QApplication>
#include <QAction>
#include <QQuickView>

#include "_debug.h"
#include "application.h"

#include <memory>

int main(int argc, char *argv[])
{
    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);
    app.setOrganizationName("georgefb");
    app.setOrganizationDomain("georgefb.com");

    // Qt sets the locale in the QGuiApplication constructor, but libmpv
    // requires the LC_NUMERIC category to be set to "C", so change it back.
    std::setlocale(LC_NUMERIC, "C");

    qmlRegisterInterface<QAction>("QAction");

    QQuickStyle::setStyle(QStringLiteral("org.kde.desktop"));
    QQuickStyle::setFallbackStyle(QStringLiteral("Fusion"));

    std::unique_ptr<Application> myApp = std::make_unique<Application>();

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.rootContext()->setContextProperty(QStringLiteral("app"), myApp.release());
    qmlRegisterUncreatableType<Application>("Application", 1, 0, "Application",
                                               QStringLiteral("Application should not be created in QML"));

    engine.load(url);

    app.exec();
}
