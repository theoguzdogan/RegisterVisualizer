#include <QtGui/QGuiApplication>
#include <QtGui/QIcon>
#include <QtQml/QQmlApplicationEngine>
#include <QtQml/QQmlContext>
#include <QCoreApplication>

#include "backend.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    Backend backend;
    QObject::connect(&backend.scriptProcess, &QProcess::readyReadStandardOutput, &backend, &Backend::processOutput);
    QCoreApplication::processEvents();

    app.setOrganizationName("Turkish Aerospace");
    app.setOrganizationDomain("Space Systems");
    app.setWindowIcon(QIcon(":/assets/tai_logo_color.svg"));

    QQmlApplicationEngine engine;


    engine.rootContext()->setContextProperty("backend", &backend); //TODO - singleton
    engine.load("qrc:/qml/main.qml");




    return app.exec();
}
