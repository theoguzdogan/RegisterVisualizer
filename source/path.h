#ifndef PATH_H
#define PATH_H

#include <QtCore/QCoreApplication>
#include <QtCore/QString>
#include <string>

namespace Path {
/**
 * Returns the path of the executable file.
 *
 * @return The path of the executable file.
 */
[[nodiscard]] static std::string getExecutablePath() {
    QString bin = QCoreApplication::applicationFilePath();
    int lastSlashIndex = bin.lastIndexOf('/');
    return bin.left(lastSlashIndex + 1).toStdString();
}

/**
 * Retrieves the setup directory.
 *
 * @return The setup directory as a QString
 */
[[nodiscard]] static std::string getSetupDir() {
    std::string executablePath = getExecutablePath();
    std::string setupDir = executablePath + "Setup/";
    return setupDir;
}
};  // namespace Path

#endif  // PATH_H