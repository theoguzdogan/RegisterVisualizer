#include <QtGui/QGuiApplication>
#include <QtGui/QIcon>
#include <QtQml/QQmlApplicationEngine>
#include <QtQml/QQmlContext>

#include "backend.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    app.setOrganizationName("Turkish Aerospace");
    app.setOrganizationDomain("Space Systems"); 
    app.setWindowIcon(QIcon(":/assets/logo_37x50.svg"));

    QQmlApplicationEngine engine;
    Backend backend;

    engine.rootContext()->setContextProperty("backend", &backend); //TODO - singleton
    engine.load("qrc:/qml/main.qml");

    return app.exec();
}