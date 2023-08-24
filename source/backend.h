#ifndef BACKEND_H
#define BACKEND_H

#include <QtCore/QtCore>

#include "treeNode.h"


class Backend : public QObject {
    Q_OBJECT

   public:
    Backend() = default;

   public slots:
    /**
     * @brief Get the list of files in "./src/reg".
     * @return QList<QString>
     */
    Q_INVOKABLE QList<QString> getFileList();
    Q_INVOKABLE QList<QString> getConfFileList();

    /**
     * @brief Set the file path to the certain .yaml file in "./src/reg" according to the moduleId
     * given.
     * @param moduleId
     */
    Q_INVOKABLE void setFilePath(int moduleId);
    Q_INVOKABLE void setConfFilePath(int configId);
    Q_INVOKABLE int returnSelectedConfigId();
    Q_INVOKABLE void resetConfigId();

    /**
     * @brief Get the list of registers from the chosen .yaml file.
     * @return QList<QString>
     */
    Q_INVOKABLE QList<QString> getRegisterList();

    /**
     * @brief Get the list of the field from the given register ID.
     * @param regId
     * @return QList<QString>
     */
    Q_INVOKABLE QList<QString> getFieldList(QString regId);

    /**
     * @brief Get the configuration type from the given fieldId. ( ConfType: [-1]->Not applicable,
     * read-only  [0]->Combo Box  [1]->Text Box )
     * @param fieldId
     * @return int
     */
    Q_INVOKABLE int getConfType(QString fieldId);
    Q_INVOKABLE int getReadable(QString fieldId);
    Q_INVOKABLE int getWriteable(QString fieldId);
    Q_INVOKABLE QString getResetValue(QString fieldId);
    Q_INVOKABLE QList<QString> getValueDescriptions(QString fieldId);
    Q_INVOKABLE QString getRegAddr();
    Q_INVOKABLE bool getRegWriteable(int regId);
    Q_INVOKABLE QString getFieldAddr();
    Q_INVOKABLE void saveConfig(QString writeValue, int base);
    Q_INVOKABLE void saveRegConfig(QString writeValueHex);
    Q_INVOKABLE QString getValueFromConfigFile();
    Q_INVOKABLE QString returnHex(QString num);
    Q_INVOKABLE void sshSet(QString address, QString value);
    Q_INVOKABLE QString fieldGet(QString address);
    Q_INVOKABLE void fieldSet(QString address, QString value);
    Q_INVOKABLE void bufferSet(QString address, QString value);
    Q_INVOKABLE QString checkBuffer(QString address);
    Q_INVOKABLE QString sshGet(QString address);
    Q_INVOKABLE int returnGlobalModuleId();
    Q_INVOKABLE QString returnGlobalRegId();
    Q_INVOKABLE QString returnGlobalFieldId();
    Q_INVOKABLE QString returnGlobalConfigId();
    Q_INVOKABLE void setDefaultConfigId(QString configName);
    Q_INVOKABLE void setGlobalModuleId(int moduleId);
    Q_INVOKABLE void setGlobalRegId(int regId);
    Q_INVOKABLE void setGlobalFieldId(int fieldId);
    Q_INVOKABLE int checkAllConfigValues(int mode, QString checkPath = "");
    Q_INVOKABLE void checkAndSaveAll(QString newFileName);
    Q_INVOKABLE int returnPinConfig(QString initSignal);
    Q_INVOKABLE QList<QString> returnPinConfig(int index);
    Q_INVOKABLE int findPinConfig(QString componentType, QString componentId);
    Q_INVOKABLE void addToPinConfig(QString componentType, QString componentId);
    Q_INVOKABLE void removeFromPinConfig(QString componentType, QString componentId);
    Q_INVOKABLE void removeFromPinConfig(int lineNumber);

   private:
    QList<QString> vectorToQList(std::vector<std::string> vector);
    int getRangeStart(std::string str);
    int getRangeEnd(std::string str);
    int countSpaces(std::string data);
    std::string deleteNonAlphaNumerical(std::string data);
    std::vector<std::string> deleteNonAlphaNumerical_Reg(std::string data);
    int getIdByName(std::string component, std::string name);
    std::string getFieldAddrByPath(std::string path);
    std::vector<int> getFieldRangeByPath(std::string path);
    std::string getRegAddrByPath(std::string path);
    std::vector<std::string> getFieldListByPath(std::string path);
    bool getIsFieldWriteOnlyByPath(std::string path);
    int searchNodeVector(std::vector<TreeNode> container, std::string key);
    TreeNode parseConfig(std::string configFilePath);
    bool isEmptySpace(std::string data);
    std::string hexToBinaryWithPadding(const std::string& hexString);
    std::string hexToBinaryWithPadding(const std::string& hexString, int bitSize);
    std::string binaryToHex(const std::string& binaryString);
    std::string reverseString(std::string str);

    int globalModuleId = -1;
    QString globalRegId = "-1";
    QString globalFieldId = "-1";
    int globalConfigId = 0;
    std::string filePath;
    std::string configFilePath = "../src/conf/default.yaml";
    std::vector<QList<QString>> globalPinConfig;
};

#endif  // BACKEND_H
