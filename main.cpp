#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include "calculator.h"

int main(int argc, char *argv[]) {
    // This forces the app to respect your custom colors instead of Mac defaults!
    QQuickStyle::setStyle("Basic"); 
    
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    
    CalculatorBackend backend;
    engine.rootContext()->setContextProperty("backend", &backend);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
