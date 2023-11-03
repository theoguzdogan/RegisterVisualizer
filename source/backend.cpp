#include "backend.h"
#include "yaml.h"
#include "path.h"
#include <QtCore/QDir>
#include <QSysInfo>
#include <QFileInfo>
#include <bitset>
#include <fstream>

using namespace std;

int Backend::returnGlobalModuleId() { return globalModuleId; }

QString Backend::returnGlobalRegId() { return globalRegId; }

QString Backend::returnGlobalFieldId() { return globalFieldId; }

QString Backend::returnGlobalConfigId() { return QString::number(globalConfigId); }

void Backend::setDefaultConfigId(QString configName) {
    globalConfigId = 0;
    QList<QString> configList = Backend::getConfFileList();
    for (int i = 0; i < configList.length(); i++) {
        if (configList[i] == configName) {
            globalConfigId = i;
            break;
        }
    }
}

void Backend::setGlobalModuleId(int moduleId) {
    globalModuleId = moduleId;
    if (moduleId >= 0) {
        Backend::setFilePath(moduleId);
    }
}

void Backend::setGlobalRegId(int regId) { globalRegId = QString::number(regId); }

void Backend::setGlobalFieldId(int fieldId) { globalFieldId = QString::number(fieldId); }

QList<QString> Backend::getFileList() {
    QDir directory(QString::fromStdString(Path::getSetupDir()) + "/Registers/");
    QStringList yamlFiles = directory.entryList(QStringList() << "*.yaml", QDir::Files);

    return yamlFiles;
}

QList<QString> Backend::getConfFileList() {
    QDir directory(QString::fromStdString(Path::getSetupDir()) + "/SavedConfigs/");
    QStringList yamlFiles = directory.entryList(QStringList() << "*.yaml", QDir::Files);

    return yamlFiles;
}

QList<QString> Backend::getGrmonScriptList() {
    QDir directory(QString::fromStdString(Path::getSetupDir()) + "/TargetMocks/grmon_imitator/python_executables");
    QStringList grmonScripts = directory.entryList(QDir::Dirs | QDir::NoDotAndDotDot );
//    QStringList grmonScripts = directory.entryList(QStringList() << "*.sh", QDir::Files);

    return grmonScripts;
}

void Backend::setFilePath(int moduleId) {
    globalModuleId = moduleId;
    filePath = Path::getSetupDir() + "/Registers/" +
               getFileList().at(moduleId).toStdString();
}

void Backend::setConfFilePath(int configId) {
    globalConfigId = configId;
    configFilePath = Path::getSetupDir() + "/SavedConfigs/" +
                     getConfFileList().at(configId).toStdString();
}

int Backend::returnSelectedConfigId() { return globalConfigId; }

void Backend::resetConfigId() { globalConfigId = -1; }

QList<QString> Backend::getRegisterList() {
    return vectorToQList(Yaml::getValueList(filePath, "RegName"));
}

QList<QString> Backend::getFieldList(QString regId) {
    if (regId != NULL) {
        globalRegId = regId;
    }

    std::vector<YAML::Node> nodeList = Yaml::getNodeListByKey(filePath, "Fields");
    return vectorToQList(Yaml::getValueList(nodeList.at(regId.toInt()), "Name"));
}

std::vector<std::string> Backend::getFieldListByPath(std::string path) {
    std::string moduleName;
    std::string regName;

    // SPLIT PATH START
    int nameSwitch = 0;
    for (int i = 0; i < path.size(); i++) {
        if (path[i] != '.') {
            switch (nameSwitch) {
            case 0:
                moduleName.push_back(path[i]);
                break;
            case 1:
                regName.push_back(path[i]);
                break;
            }
        } else {
            nameSwitch++;
        }
    }
    // SPLIT PATH START

    // GET COMPONENT IDs START
    int moduleId = -1;
    QList<QString> fileList = Backend::getFileList();
    for (int i = 0; i < fileList.size(); i++) {
        std::string temp = fileList.at(i).toStdString();
        for (int j = 0; j < 5; ++j) {
            temp.pop_back();
        }
        if (moduleName == temp) {
            moduleId = i;
            break;
        }
    }

    int regId = -1;
    QList<QString> regList = vectorToQList(
        Yaml::getValueList(Path::getSetupDir() + "/Registers/" +
                               getFileList().at(moduleId).toStdString(),
                           "RegName"));
    for (int i = 0; i < regList.size(); i++) {
        if (regList.at(i).toStdString() == regName) {
            regId = i;
        }
    }

    if (moduleId == -1) {
        qDebug() << "INVALID MODULE on function Backend::getFieldAddrByPath()";
    }

    if (regId == -1) {
        qDebug() << "INVALID REGISTER on function Backend::getFieldAddrByPath()";
    }

    // GET COMPONENT IDs END
    std::string filePath = Path::getSetupDir() + "/Registers/" +
                           moduleName + ".yaml";
    std::vector<YAML::Node> nodeList = Yaml::getNodeListByKey(filePath, "Fields");

    return Yaml::getValueList(nodeList.at(regId), "Name");
}

int Backend::getConfType(QString fieldId) {
    globalFieldId = fieldId;
    std::vector<YAML::Node> nodeList = Yaml::getNodeListByKey(filePath, "Fields");

    return vectorToQList(Yaml::getValueList(nodeList.at(globalRegId.toInt()), "ConfType"))
        .at(fieldId.toInt())
        .toInt();
}

int Backend::getReadable(QString fieldId) {
    globalFieldId = fieldId;
    std::vector<YAML::Node> nodeList = Yaml::getNodeListByKey(filePath, "Fields");
    return vectorToQList(Yaml::getValueList(nodeList.at(globalRegId.toInt()), "Read"))
        .at(fieldId.toInt())
        .toInt();
}

int Backend::getWriteable(QString fieldId) {
    globalFieldId = fieldId;
    std::vector<YAML::Node> nodeList = Yaml::getNodeListByKey(filePath, "Fields");
    return vectorToQList(Yaml::getValueList(nodeList.at(globalRegId.toInt()), "Write"))
        .at(fieldId.toInt())
        .toInt();
}

QList<QString> Backend::getValueDescriptions(QString fieldId) {
    globalFieldId = fieldId;
    std::vector<YAML::Node> regNodeList = Yaml::getNodeListByKey(filePath, "Fields");
    YAML::Node regNode = regNodeList.at(globalRegId.toInt());
    std::string regName = Yaml::getValue(regNode, "RegName");

    std::vector<YAML::Node> fieldNodeList = Yaml::searchNodeByKey(regNode, "Name");
    YAML::Node fieldNode = fieldNodeList.at(globalFieldId.toInt());
    std::string fieldName = Yaml::getValue(fieldNode, "Name");

    std::string valueNodePath = regName + ".Fields." + fieldName + ".Value";

    YAML::Node valueNode = Yaml::getNodeByPath(filePath, valueNodePath);
    std::vector<std::string> result = valueNode.as<std::vector<std::string>>();

    return vectorToQList(result);
}

QString Backend::getResetValue(QString fieldId) {
    globalFieldId = fieldId;
    std::vector<YAML::Node> nodeList = Yaml::getNodeListByKey(filePath, "Fields");
    return vectorToQList(Yaml::getValueList(nodeList.at(globalRegId.toInt()), "ResetValue"))
        .at(fieldId.toInt());
}

QString Backend::getRegAddr() {
    std::string moduleAddr = Yaml::getValue(filePath, "Module_ADDR");
    QString regAddr =
        Backend::vectorToQList(Yaml::getValueList(filePath, "ADDR")).at(globalRegId.toInt());

    int moduleAddrInt = std::stoi(moduleAddr, 0, 16);
    int regAddrInt = std::stoi(regAddr.toStdString(), 0, 16);
    int sum = moduleAddrInt + regAddrInt;

    std::stringstream temp;
    temp << std::hex << sum;

    QString sumStr = QString::fromStdString("0x" + temp.str());

    return sumStr;
}

bool Backend::getRegWriteable(int regId){
    int fieldAmount = Backend::getFieldList(Backend::returnGlobalRegId()).length();
    bool isWriteable = false;
    for (int i = 0; i < fieldAmount; i++) {
        std::vector<YAML::Node> nodeList = Yaml::getNodeListByKey(filePath, "Fields");
        int isFieldWriteable = vectorToQList(Yaml::getValueList(nodeList.at(regId), "Write")).at(i).toInt();
        if (isFieldWriteable == 1){
            isWriteable = true;
            break;
        }
    }

    return isWriteable;
}

QString Backend::getFieldAddr() {
    std::string moduleAddr = Yaml::getValue(filePath, "Module_ADDR");
    QString regAddr =
        Backend::vectorToQList(Yaml::getValueList(filePath, "ADDR")).at(globalRegId.toInt());
    std::vector<YAML::Node> nodeList = Yaml::getNodeListByKey(filePath, "Fields");
    std::string fieldRange =
        vectorToQList(Yaml::getValueList(nodeList.at(globalRegId.toInt()), "Range"))
            .at(globalFieldId.toInt())
            .toStdString();

    int moduleAddrInt = std::stoi(moduleAddr, 0, 16);
    int regAddrInt = std::stoi(regAddr.toStdString(), 0, 16);
    int fieldRangeStart = getRangeStart(fieldRange);
    int sum = moduleAddrInt + regAddrInt + fieldRangeStart;

    std::stringstream temp;
    temp << std::hex << sum;

    QString sumStr = QString::fromStdString("0x" + temp.str());

    return sumStr;
}

int Backend::getRangeStart(std::string str) {
    for (int i = str.length(); i >= 0; --i) {
        if (str[i] == ',') {
            str.erase(i);
        }
    }
    str.erase(0, 1);

    return std::stoi(str);
}

int Backend::getRangeEnd(std::string str) {
    int delimiter;
    for (int i = 0; i <= str.length(); ++i) {
        if (str[i] == ',') {
            delimiter = i;
            break;
        }
    }
    str.erase(0, delimiter + 1);
    str.erase(str.length() - 1, str.length());

    return std::stoi(str);
}

void Backend::saveConfig(QString writeValue, int base) {
    QString writeValueHex;
    if (base == 10) {
        writeValueHex = "0x" + QString::number(writeValue.toInt(), 16);
    } else if (base == 16) {
        writeValueHex = writeValue;
    }

    std::string moduleName = Backend::getFileList().at(globalModuleId).toStdString();

    for (int i = moduleName.length(); i >= 0; --i) {
        if (moduleName[i] == '.') {
            moduleName.erase(i);
        }
    }

    std::string regName = Backend::getRegisterList().at(globalRegId.toInt()).toStdString();
    std::string fieldName =
        Backend::getFieldList(globalRegId).at(globalFieldId.toInt()).toStdString();

    TreeNode root = parseConfig(configFilePath);

    bool found = false;

    for (int moduleNo = 0; moduleNo < root.children.size(); moduleNo++) {
        TreeNode* module = &root.children.at(moduleNo);
        if (module->name == moduleName) {
            for (int regNo = 0; regNo < module->children.size(); regNo++) {
                TreeNode* reg = &module->children.at(regNo);
                if (reg->name == regName) {
                    for (int fieldNo = 0; fieldNo < reg->children.size(); fieldNo++) {
                        TreeNode* field = &reg->children.at(fieldNo);
                        if (field->name == fieldName) {
                            if (writeValue != "-1") {
                                field->value = writeValueHex.toStdString();
                            }

                            found = true;
                            break;
                        }
                    }
                    if (!found) {
                        if (writeValue != "-1") {
                            TreeNode newField(reg, fieldName, 3, writeValueHex.toStdString());
                            reg->addChild(newField);
                        }
                    }
                    break;
                }
            }
            break;
        }
    }

    std::ofstream outfile;
    outfile.open(configFilePath);
    bool is_firstLine = true;

    foreach (TreeNode module, root.children) {
        if (is_firstLine) {
            is_firstLine = false;
        } else {
            outfile << endl;
        }

        outfile << module.name + ':' << endl;
        foreach (TreeNode reg, module.children) {
            outfile << ' ' + reg.name + ':' << endl;
            foreach (TreeNode field, reg.children) {
                outfile << "  - " + field.name + ": " << field.value << endl;
            }
        }
    }

    outfile.close();
}

void Backend::saveRegConfig(QString writeValueHex) {
    std::string moduleName = Backend::getFileList().at(globalModuleId).toStdString();

    for (int i = moduleName.length(); i >= 0; --i) {
        if (moduleName[i] == '.') {
            moduleName.erase(i);
        }
    }

    std::string regName = Backend::getRegisterList().at(globalRegId.toInt()).toStdString();

    TreeNode root = parseConfig(configFilePath);

    bool found = false;
    for (int moduleNo = 0; moduleNo < root.children.size(); moduleNo++) {
        TreeNode* module = &root.children.at(moduleNo);
        if (module->name == moduleName) {
            for (int regNo = 0; regNo < module->children.size(); regNo++) {
                TreeNode* reg = &module->children.at(regNo);
                if (reg->name == regName) {
                    if (writeValueHex != "-1") {
                        reg->value = writeValueHex.toStdString();
                    }
                    found = true;
                    break;
                }
            }
            if (!found) {
                if (writeValueHex != "-1") {
                    TreeNode newReg(module, regName, 2, writeValueHex.toStdString());
                    module->addChild(newReg);
                }
            }
            break;
        }
    }

    std::ofstream outfile;
    outfile.open(configFilePath);
    bool is_firstLine = true;

    foreach (TreeNode module, root.children) {
        if (is_firstLine) {
            is_firstLine = false;
        } else {
            outfile << endl;
        }

        outfile << module.name + ':' << endl;
        foreach (TreeNode reg, module.children) {
            outfile << ' ' + reg.name + ": " << reg.value << endl;
        }
    }

    outfile.close();
}

TreeNode Backend::parseConfig(std::string configFilePath) {
    // READ_FILE
    std::ifstream infile;
    infile.open(configFilePath);
    std::vector<std::string> lines;
    std::string buffer;

    while (getline(infile, buffer)) {
        lines.push_back(buffer);
    }

    infile.close();

    // INSERT INTO TREE
    TreeNode root("ROOT", -1);
    TreeNode* modulePtrHolder;

    foreach (std::string line, lines) {
        if (Backend::isEmptySpace(line)) {
            continue;
        }
        int degree = Backend::countSpaces(line);

        // MODULE INSERT
        if (degree == 0) {
            std::string name = Backend::deleteNonAlphaNumerical(line);
            TreeNode newNode(&root, name, degree);
            root.addChild(newNode);
            modulePtrHolder = &root.children.at(root.children.size() - 1);
        }

        // REGISTER INSERT
        else if (degree == 1) {
            std::string name = Backend::deleteNonAlphaNumerical_Reg(line).at(0);
            std::string value = Backend::deleteNonAlphaNumerical_Reg(line).at(1);
            TreeNode newNode(modulePtrHolder, name, degree, value);
            modulePtrHolder->addChild(newNode);
        }
    }

    // RETURN ROOT NODE OF THE TREE
    return root;
}

bool Backend::isEmptySpace(std::string data) {
    if (data == "") {
        return true;
    } else {
        foreach (char character, data) {
            if (character != ' ') {
                return false;
            }
        }
        return true;
    }
}

QString Backend::getValueFromConfigFile() {
    TreeNode root = parseConfig(configFilePath);
    std::string moduleName = Backend::getFileList().at(globalModuleId).toStdString();

    for (int i = 0; i < 5; ++i) {
        moduleName.pop_back();
    }
    std::string regName = Backend::getRegisterList().at(globalRegId.toInt()).toStdString();
    std::string fieldName =
        Backend::getFieldList(globalRegId).at(globalFieldId.toInt()).toStdString();
    foreach (TreeNode module, root.children) {
        if (module.name == moduleName) {
            foreach (TreeNode reg, module.children) {
                if (reg.name == regName) {
                    // fieldcheck
                    std::string regValue = reg.value;
                    std::string regValue_Bin = Backend::hexToBinaryWithPadding(regValue);
                    std::string regValue_Bin_Reversed = Backend::reverseString(regValue_Bin);

                    std::vector<std::string> fieldList =
                        Backend::getFieldListByPath(moduleName + '.' + regName);
                    std::vector<int> fieldRange =
                        Backend::getFieldRangeByPath(moduleName + '.' + regName + '.' + fieldName);
                    std::string value;
                    for (int i = fieldRange[0]; i < fieldRange[1]; i++) {
                        value.push_back(regValue_Bin_Reversed.at(i));
                    }
                    return QString::fromStdString(
                        Backend::binaryToHex(Backend::reverseString(value)));
                }
            }
        }
    }
    return "-1";
}

std::string Backend::getRegAddrByPath(std::string path) {
    std::string moduleName;
    std::string regName;

    // SPLIT PATH START
    int nameSwitch = 0;
    for (int i = 0; i < path.size(); i++) {
        if (path[i] != '.') {
            switch (nameSwitch) {
            case 0:
                moduleName.push_back(path[i]);
                break;
            case 1:
                regName.push_back(path[i]);
                break;
            }
        } else {
            nameSwitch++;
        }
    }
    // SPLIT PATH END

    // GET COMPONENT IDs START
    int moduleId = -1;
    QList<QString> fileList = Backend::getFileList();
    for (int i = 0; i < fileList.size(); i++) {
        std::string temp = fileList.at(i).toStdString();
        for (int j = 0; j < 5; ++j) {
            temp.pop_back();
        }
        if (moduleName == temp) {
            moduleId = i;
            break;
        }
    }

    int regId = -1;
    QList<QString> regList = vectorToQList(
        Yaml::getValueList(Path::getSetupDir() + "/Registers/" +
                               getFileList().at(moduleId).toStdString(),
                           "RegName"));
    for (int i = 0; i < regList.size(); i++) {
        if (regList.at(i).toStdString() == regName) {
            regId = i;
        }
    }

    if (moduleId == -1) {
        qDebug() << "INVALID MODULE on function Backend::getFieldAddrByPath()";
    }
    if (regId == -1) {
        qDebug() << "INVALID REGISTER on function Backend::getFieldAddrByPath()";
    }
    // GET COMPONENT IDs END

    // CALCULATE ADDR START
    std::string moduleAddr =
        Yaml::getValue(Path::getSetupDir() + "/Registers/" +
                           getFileList().at(moduleId).toStdString(),
                       "Module_ADDR");
    QString regAddr =
        Backend::vectorToQList(Yaml::getValueList(Path::getSetupDir() +
                                                      "/Registers/" +
                                                      getFileList().at(moduleId).toStdString(),
                                                  "ADDR"))
            .at(regId);

    int moduleAddrInt = std::stoi(moduleAddr, 0, 16);
    int regAddrInt = std::stoi(regAddr.toStdString(), 0, 16);

    int sum = moduleAddrInt + regAddrInt;
    // CALCULATE ADDR END

    std::stringstream temp;
    temp << std::hex << sum;

    return ("0x" + temp.str());
}

std::string Backend::getFieldAddrByPath(std::string path) {
    std::string moduleName;
    std::string regName;
    std::string fieldName;

    // SPLIT PATH START
    int nameSwitch = 0;
    for (int i = 0; i < path.size(); i++) {
        if (path[i] != '.') {
            switch (nameSwitch) {
            case 0:
                moduleName.push_back(path[i]);
                break;
            case 1:
                regName.push_back(path[i]);
                break;
            case 2:
                fieldName.push_back(path[i]);
                break;
            }
        } else {
            nameSwitch++;
        }
    }
    // SPLIT PATH END

    // GET COMPONENT IDs START
    int moduleId = -1;
    QList<QString> fileList = Backend::getFileList();
    for (int i = 0; i < fileList.size(); i++) {
        std::string temp = fileList.at(i).toStdString();
        for (int j = 0; j < 5; ++j) {
            temp.pop_back();
        }
        if (moduleName == temp) {
            moduleId = i;
            break;
        }
    }

    int regId = -1;
    QList<QString> regList = vectorToQList(
        Yaml::getValueList(Path::getSetupDir() + "/Registers/" +
                               getFileList().at(moduleId).toStdString(),
                           "RegName"));
    for (int i = 0; i < regList.size(); i++) {
        if (regList.at(i).toStdString() == regName) {
            regId = i;
        }
    }

    int fieldId = -1;
    QList<QString> fieldList;
    std::vector<YAML::Node> nodeList =
        Yaml::getNodeListByKey(Path::getSetupDir() +
                                   "/Registers/" + getFileList().at(moduleId).toStdString(),
                               "Fields");
    fieldList = vectorToQList(Yaml::getValueList(nodeList.at(regId), "Name"));
    for (int i = 0; i < fieldList.size(); i++) {
        if (fieldList.at(i).toStdString() == fieldName) {
            fieldId = i;
        }
    }

    if (moduleId == -1) {
        qDebug() << "INVALID MODULE on function Backend::getFieldAddrByPath()";
    }
    if (regId == -1) {
        qDebug() << "INVALID REGISTER on function Backend::getFieldAddrByPath()";
    }
    if (fieldId == -1) {
        qDebug() << "INVALID FIELD on function Backend::getFieldAddrByPath()";
    }
    // GET COMPONENT IDs END

    // CALCULATE ADDR START
    std::string moduleAddr =
        Yaml::getValue(Path::getSetupDir() + "/Registers/" +
                           getFileList().at(moduleId).toStdString(),
                       "Module_ADDR");
    QString regAddr =
        Backend::vectorToQList(Yaml::getValueList(Path::getSetupDir() +
                                                      "/Registers/" +
                                                      getFileList().at(moduleId).toStdString(),
                                                  "ADDR"))
            .at(regId);
    std::string fieldRange =
        vectorToQList(Yaml::getValueList(nodeList.at(regId), "Range")).at(fieldId).toStdString();

    int moduleAddrInt = std::stoi(moduleAddr, 0, 16);
    int regAddrInt = std::stoi(regAddr.toStdString(), 0, 16);
    int fieldRangeStart = getRangeStart(fieldRange);
    int sum = moduleAddrInt + regAddrInt + fieldRangeStart;
    // CALCULATE ADDR END

    std::stringstream temp;
    temp << std::hex << sum;

    return ("0x" + temp.str());
}

std::vector<int> Backend::getFieldRangeByPath(std::string path) {
    std::string moduleName;
    std::string regName;
    std::string fieldName;

    // SPLIT PATH START
    int nameSwitch = 0;
    for (int i = 0; i < path.size(); i++) {
        if (path[i] != '.') {
            switch (nameSwitch) {
            case 0:
                moduleName.push_back(path[i]);
                break;
            case 1:
                regName.push_back(path[i]);
                break;
            case 2:
                fieldName.push_back(path[i]);
                break;
            }
        } else {
            nameSwitch++;
        }
    }
    // SPLIT PATH END

    // GET COMPONENT IDs START
    int moduleId = -1;
    QList<QString> fileList = Backend::getFileList();
    for (int i = 0; i < fileList.size(); i++) {
        std::string temp = fileList.at(i).toStdString();
        for (int j = 0; j < 5; ++j) {
            temp.pop_back();
        }
        if (moduleName == temp) {
            moduleId = i;
            break;
        }
    }

    int regId = -1;
    QList<QString> regList = vectorToQList(
        Yaml::getValueList(Path::getSetupDir() + "/Registers/" +
                               getFileList().at(moduleId).toStdString(),
                           "RegName"));
    for (int i = 0; i < regList.size(); i++) {
        if (regList.at(i).toStdString() == regName) {
            regId = i;
        }
    }

    int fieldId = -1;
    QList<QString> fieldList;
    std::vector<YAML::Node> nodeList =
        Yaml::getNodeListByKey(Path::getSetupDir() +
                                   "/Registers/" + getFileList().at(moduleId).toStdString(),
                               "Fields");
    fieldList = vectorToQList(Yaml::getValueList(nodeList.at(regId), "Name"));
    for (int i = 0; i < fieldList.size(); i++) {
        if (fieldList.at(i).toStdString() == fieldName) {
            fieldId = i;
        }
    }

    if (moduleId == -1) {
        qDebug() << "INVALID MODULE on function Backend::getFieldRangeByPath()";
    }
    if (regId == -1) {
        qDebug() << "INVALID REGISTER on function Backend::getFieldRangeByPath()";
    }
    if (fieldId == -1) {
        qDebug() << "INVALID FIELD on function Backend::getFieldRangeByPath()";
    }
    // GET COMPONENT IDs END

    std::string fieldRange =
        vectorToQList(Yaml::getValueList(nodeList.at(regId), "Range")).at(fieldId).toStdString();

    std::vector<int> rangeResult;
    rangeResult.push_back(getRangeStart(fieldRange));
    rangeResult.push_back(getRangeEnd(fieldRange));

    return rangeResult;
}

bool Backend::getIsFieldWriteOnlyByPath(std::string path) {
    std::string moduleName;
    std::string regName;
    std::string fieldName;

    // SPLIT PATH START
    int nameSwitch = 0;
    for (int i = 0; i < path.size(); i++) {
        if (path[i] != '.') {
            switch (nameSwitch) {
            case 0:
                moduleName.push_back(path[i]);
                break;
            case 1:
                regName.push_back(path[i]);
                break;
            case 2:
                fieldName.push_back(path[i]);
                break;
            }
        } else {
            nameSwitch++;
        }
    }
    // SPLIT PATH END

    // GET COMPONENT IDs START
    int moduleId = -1;
    QList<QString> fileList = Backend::getFileList();
    for (int i = 0; i < fileList.size(); i++) {
        std::string temp = fileList.at(i).toStdString();
        for (int j = 0; j < 5; ++j) {
            temp.pop_back();
        }
        if (moduleName == temp) {
            moduleId = i;
            break;
        }
    }

    int regId = -1;
    QList<QString> regList = vectorToQList(
        Yaml::getValueList(Path::getSetupDir() + "/Registers/" +
                               getFileList().at(moduleId).toStdString(),
                           "RegName"));
    for (int i = 0; i < regList.size(); i++) {
        if (regList.at(i).toStdString() == regName) {
            regId = i;
        }
    }

    int fieldId = -1;
    QList<QString> fieldList;
    std::vector<YAML::Node> nodeList =
        Yaml::getNodeListByKey(Path::getSetupDir() +
                                   "/Registers/" + getFileList().at(moduleId).toStdString(),
                               "Fields");
    fieldList = vectorToQList(Yaml::getValueList(nodeList.at(regId), "Name"));
    for (int i = 0; i < fieldList.size(); i++) {
        if (fieldList.at(i).toStdString() == fieldName) {
            fieldId = i;
        }
    }

    if (moduleId == -1) {
        qDebug() << "INVALID MODULE on function Backend::getFieldWriteableByPath()";
    }
    if (regId == -1) {
        qDebug() << "INVALID REGISTER on function Backend::getFieldWriteableByPath()";
    }
    if (fieldId == -1) {
        qDebug() << "INVALID FIELD on function Backend::getFieldWriteableByPath()";
    }
    // GET COMPONENT IDs END

    // GET IS READ-WRITEABLE START
    nodeList =
        Yaml::getNodeListByKey(Path::getSetupDir() +
                                   "/Registers/" + getFileList().at(moduleId).toStdString(),
                               "Fields");
    bool is_writeable =
        vectorToQList(Yaml::getValueList(nodeList.at(regId), "Write")).at(fieldId).toInt();
    bool is_readable =
        vectorToQList(Yaml::getValueList(nodeList.at(regId), "Read")).at(fieldId).toInt();
    // GET IS READ-WRITEABLE END

    return (is_writeable && !is_readable);
}

int Backend::checkAllConfigValues(int mode, QString checkPath) {
    static std::vector<std::string> redModules;
    static std::vector<std::string> redRegs;
    static std::vector<std::string> redFields;

    // INITIALIZING MODE
    if (mode == -1) {
        TreeNode root = parseConfig(configFilePath);

        redModules.clear();
        redRegs.clear();
        redFields.clear();

        for (int moduleIt = 0; moduleIt < root.children.size(); moduleIt++) {
            for (int regIt = 0; regIt < root.children.at(moduleIt).children.size(); regIt++) {
                std::string moduleName = root.children.at(moduleIt).name;
                std::string regName = root.children.at(moduleIt).children.at(regIt).name;
                std::string regValue = root.children.at(moduleIt).children.at(regIt).value;
                std::string regTargetValue =
                    Backend::grmonGet(
                        QString::fromStdString(getRegAddrByPath(moduleName + '.' + regName)))
                        .toStdString();

                if (regValue != regTargetValue) {
                    redRegs.push_back(moduleName + '.' + regName);

                    bool isAvailable = false;
                    foreach (std::string mod, redModules) {
                        if (mod == moduleName) {
                            isAvailable = true;
                            break;
                        }
                    }

                    if (!isAvailable) {
                        redModules.push_back(moduleName);
                    }
                }

                // FIELD CHECK
                std::string regTargetValue_Bin = Backend::hexToBinaryWithPadding(regTargetValue);
                std::string regValue_Bin = Backend::hexToBinaryWithPadding(regValue);

                std::vector<std::string> fieldList =
                    Backend::getFieldListByPath(moduleName + '.' + regName);
                foreach (std::string fieldName, fieldList) {
                    std::vector<int> fieldRange =
                        Backend::getFieldRangeByPath(moduleName + '.' + regName + '.' + fieldName);
                    for (int i = fieldRange[0]; i < fieldRange[1]; i++) {
                        if (Backend::reverseString(regValue_Bin)[i] !=
                            Backend::reverseString(regTargetValue_Bin)[i]) {
                            redFields.push_back(moduleName + '.' + regName + '.' + fieldName);
                            break;
                        }
                    }
                }
            }
        }
        Backend::configState = 1;
        return -1;
    }

    // MODULE CHECK MODE
    else if (mode == 0) {
        foreach (QString module, Backend::vectorToQList(redModules)) {
            if (module == checkPath) {
                return 1;
            }
        }
        return 0;
    }

    // REGISTER CHECK MODE
    else if (mode == 1) {
        foreach (QString reg, Backend::vectorToQList(redRegs)) {
            if (reg == checkPath) {
                return 1;
            }
        }
        return 0;
    }

    // FIELD CHECK MODE
    else if (mode == 2) {
        foreach (QString field, Backend::vectorToQList(redFields)) {
            if (field == checkPath) {
                return 1;
            }
        }
        return 0;
    }

    // INVALID MODE SELECTION
    else {
        return -1;
    }
}

int Backend::returnConfigState(){return Backend::configState;}

QString Backend::returnHex(QString num) { return "0x" + QString::number(num.toInt(), 16); }

int Backend::countSpaces(std::string data) {
    int counter = 0;
    foreach (char character, data) {
        if (character == ' ') {
            counter++;
        } else {
            break;
        }
    }
    return counter;
}

void Backend::grmonSet(QString address, QString value) {
    Backend::sendScriptCommand("wmem "+address+" "+value);
    Backend::scriptProcess.waitForReadyRead();
}

QString Backend::fieldGet(QString address) {
    // GET BUFFER FILE LINES AND CHECK IF THE ADDRESS EXISTS
    std::ifstream bufferFile;
    bufferFile.open(Path::getSetupDir() + "/buffer.yaml");
    std::vector<std::string> bufferLines;
    std::string buffer;

    while (std::getline(bufferFile, buffer)) {
        bufferLines.push_back(buffer);
    }

    bufferFile.close();
    int i;
    std::string temp;
    bool foundBuffer = false;

    for (i = 0; i < bufferLines.size(); i++) {
        std::string line = bufferLines.at(i);
        temp.clear();
        for (int j = 0; j < line.size(); j++) {
            if (line.at(j) == ':') {
                break;
            }
            temp.push_back(line[j]);
        }

        if (temp == address.toStdString()) {
            foundBuffer = true;
            break;
        }
    }
    std::string line;  // Common variable to store line.

    if (foundBuffer) {  // IF ADDRESS FOUND IN BUFFER, COPY FOUND LINE TO THE COMMON VARIABLE
        line = bufferLines.at(i);
    } else {  // IF NOT, SEARCH THE TARGET FILE
        line = (address+": "+grmonGet(address)).toStdString();
    }

    // IF ADDRESS FOUND ON EITHER OF RESOURCES GET FIELD VALUE FROM THE RELEVANT PLACE OF REGISTER VALUE
    temp.clear();
    bool valueSwitch = false;
    for (int j = 0; j < line.size(); j++) {
        if (line[j] == ' ') {
            continue;
        }
        if (valueSwitch) {
            temp.push_back(line[j]);
        }
        if (line.at(j) == ':') {
            valueSwitch = true;
        }
    }
    std::string initialHex = temp;
    std::string initialBin = Backend::hexToBinaryWithPadding(initialHex);
    initialBin = Backend::reverseString(initialBin);  // REVERSED BINARY VALUE FOR ENDIANNESS
    std::vector<YAML::Node> nodeList = Yaml::getNodeListByKey(filePath, "Fields");
    std::string fieldRange =
        vectorToQList(Yaml::getValueList(nodeList.at(globalRegId.toInt()), "Range"))
            .at(globalFieldId.toInt())
            .toStdString();
    int fieldRangeStart = getRangeStart(fieldRange);
    int fieldRangeEnd = getRangeEnd(fieldRange);

    std::string binaryValue;

    for (int i = 0; i < (fieldRangeEnd - fieldRangeStart); i++) {
        binaryValue.push_back(initialBin[fieldRangeStart + i]);
    }
    for (int i = 0; i < 32 - (fieldRangeEnd - fieldRangeStart); i++) {
        binaryValue.push_back('0');
    }
    binaryValue = Backend::reverseString(binaryValue);  // REVERSED BACK BINARY VALUE FOR ENDIANNESS
    std::string hexValue = Backend::binaryToHex(binaryValue);
    return QString::fromStdString(hexValue);
}

QString Backend::fieldGetFromTarget(QString address) {
    std::string line = (address + ": " + grmonGet(address)).toStdString();

    std::string temp = "";
    bool valueSwitch = false;
    for (int j = 0; j < line.size(); j++) {
        if (line[j] == ' ') {
            continue;
        }
        if (valueSwitch) {
            temp.push_back(line[j]);
        }
        if (line.at(j) == ':') {
            valueSwitch = true;
        }
    }
    std::string initialHex = temp;
    std::string initialBin = Backend::hexToBinaryWithPadding(initialHex);
    initialBin = Backend::reverseString(initialBin);  // REVERSED BINARY VALUE FOR ENDIANNESS
    std::vector<YAML::Node> nodeList = Yaml::getNodeListByKey(filePath, "Fields");
    std::string fieldRange =
        vectorToQList(Yaml::getValueList(nodeList.at(globalRegId.toInt()), "Range"))
            .at(globalFieldId.toInt())
            .toStdString();
    int fieldRangeStart = getRangeStart(fieldRange);
    int fieldRangeEnd = getRangeEnd(fieldRange);

    std::string binaryValue;

    for (int i = 0; i < (fieldRangeEnd - fieldRangeStart); i++) {
        binaryValue.push_back(initialBin[fieldRangeStart + i]);
    }
    for (int i = 0; i < 32 - (fieldRangeEnd - fieldRangeStart); i++) {
        binaryValue.push_back('0');
    }
    binaryValue = Backend::reverseString(binaryValue);  // REVERSED BACK BINARY VALUE FOR ENDIANNESS
    std::string hexValue = Backend::binaryToHex(binaryValue);
    return QString::fromStdString(hexValue);
}

void Backend::fieldSet(QString address, QString value) {
    // GET BUFFER FILE LINES AND CHECK IF THE ADDRESS EXISTS
    std::ifstream bufferFile;
    bufferFile.open(Path::getSetupDir() + "/buffer.yaml");
    std::vector<std::string> bufferLines;
    std::string buffer;

    while (std::getline(bufferFile, buffer)) {
        bufferLines.push_back(buffer);
    }

    bufferFile.close();
    int i;
    std::string temp;
    bool foundBuffer = false;

    for (i = 0; i < bufferLines.size(); i++) {
        std::string line = bufferLines.at(i);
        temp.clear();
        for (int j = 0; j < line.size(); j++) {
            if (line.at(j) == ':') {
                break;
            }
            temp.push_back(line[j]);
        }

        if (temp == address.toStdString()) {
            foundBuffer = true;
            break;
        }
    }
    std::string line;  // Common variable to store line.

    if (foundBuffer) {  // IF ADDRESS FOUND IN BUFFER, COPY FOUND LINE TO THE COMMON VARIABLE
        line = bufferLines.at(i);
    } else {  // IF NOT GET FROM THE TARGET
        line = (address + ": " + grmonGet(address)).toStdString();
    }

    // IF ADDRESS FOUND ON EITHER OF RESOURCES APPLY FIELD VALUE ON THE RELEVANT PLACE OF REGISTER VALUE
    temp.clear();
    bool valueSwitch = false;
    for (int j = 0; j < line.size(); j++) {
        if (line[j] == ' ') {
            continue;
        }
        if (valueSwitch) {
            temp.push_back(line[j]);
        }
        if (line.at(j) == ':') {
            valueSwitch = true;
        }
    }
    std::string initialHex = temp;
    std::string initialBin = Backend::hexToBinaryWithPadding(initialHex);
    initialBin = Backend::reverseString(initialBin);  // REVERSED BINARY VALUE FOR ENDIANNESS
    std::vector<YAML::Node> nodeList = Yaml::getNodeListByKey(filePath, "Fields");
    std::string fieldRange =
        vectorToQList(Yaml::getValueList(nodeList.at(globalRegId.toInt()), "Range"))
            .at(globalFieldId.toInt())
            .toStdString();
    int fieldRangeStart = getRangeStart(fieldRange);
    int fieldRangeEnd = getRangeEnd(fieldRange);

    std::string binaryValue =
        Backend::hexToBinaryWithPadding(value.toStdString(), (fieldRangeEnd - fieldRangeStart));

    std::string resultBin = initialBin;

    for (int i = 0; i < (fieldRangeEnd - fieldRangeStart); i++) {
        resultBin[fieldRangeStart + i] = binaryValue[i];
    }
    resultBin = Backend::reverseString(resultBin);  // REVERSED BACK BINARY VALUE FOR ENDIANNESS
    std::string resultHex = Backend::binaryToHex(resultBin);
    Backend::bufferSet(address, QString::fromStdString(resultHex));
}

std::string Backend::hexToBinaryWithPadding(const std::string& hexString) {
    // Remove the "0x" prefix if it exists
    std::string hexValue = hexString;
    if (hexString.size() >= 2 && hexString.substr(0, 2) == "0x") {
        hexValue = hexString.substr(2);
    }

    // Convert the hexadecimal string to binary
    unsigned long long int decimalValue;
    try {
        decimalValue = std::stoull(hexValue, nullptr, 16);
    } catch (const std::invalid_argument& e) {
        qDebug() << "Invalid hexadecimal string: " << QString::fromStdString(hexString);
        return "";
    } catch (const std::out_of_range& e) {
        qDebug() << "Hexadecimal value out of range: " << QString::fromStdString(hexString);
        return "";
    }

    // Convert decimal value to 32-bit binary
    std::string binaryString = std::bitset<32>(decimalValue).to_string();

    return binaryString;
}

std::string Backend::hexToBinaryWithPadding(const std::string& hexString, int bitSize) {
    std::string hexValue = hexString;
    if (hexString.size() >= 2 && hexString.substr(0, 2) == "0x") {
        hexValue = hexString.substr(2);
    }

    // Convert the hexadecimal string to binary
    unsigned long long int decimalValue;
    try {
        decimalValue = std::stoull(hexValue, nullptr, 16);
    } catch (const std::invalid_argument& e) {
        qDebug() << "Invalid hexadecimal string: " << QString::fromStdString(hexString);
        return "";
    } catch (const std::out_of_range& e) {
        qDebug() << "Hexadecimal value out of range: " << QString::fromStdString(hexString);
        return "";
    }

    // Convert decimal value to 32-bit binary
    std::string binaryString = std::bitset<32>(decimalValue).to_string();

    binaryString.erase(0, (32 - bitSize));

    return binaryString;
}

std::string Backend::binaryToHex(const std::string& binaryString) {
    // Calculate the number of bits in the input binary string
    size_t numBits = binaryString.size();

    // Ensure that the input binary string has at least 1 bit
    if (numBits < 1) {
        qDebug() << "Input binary string should have at least 1 bit.";
        return "";
    }

    // Convert binary string to decimal value
    unsigned long int decimalValue = 0;
    for (size_t i = 0; i < numBits; ++i) {
        if (binaryString[i] == '1') {
            decimalValue |= (1 << (numBits - i - 1));
        } else if (binaryString[i] != '0') {
            qDebug() << "Invalid character in the input binary string.";
            return "";
        }
    }

    // Convert decimal value to hexadecimal string
    std::stringstream ss;
    ss << "0x" << std::hex << std::uppercase << decimalValue;

    return ss.str();
}

std::string Backend::reverseString(std::string str) {
    int halfLength = (str.length() / 2) + (0.5);
    for (int i = 0; i < halfLength; i++) {
        char temp = str[i];
        str[i] = str[str.length() - (i + 1)];
        str[str.length() - (i + 1)] = temp;
    }
    return str;
}

void Backend::bufferSet(QString address, QString value) {
    if(Backend::getRegWriteable(globalRegId.toInt())) {
        std::ifstream infile;
        infile.open(Path::getSetupDir() + "/buffer.yaml");
        std::vector<std::string> lines;
        std::string buffer;

        while (std::getline(infile, buffer)) {
            lines.push_back(buffer);
        }

        infile.close();
        int i;
        std::string temp;
        bool found = false;

        for (i = 0; i < lines.size(); i++) {
            std::string line = lines.at(i);
            temp.clear();
            for (int j = 0; j < line.size(); j++) {
                if (line.at(j) == ':') {
                    break;
                }
                temp.push_back(line[j]);
            }

            if (temp == address.toStdString()) {
                found = true;
                break;
            }
        }

        if (found) {
            lines.at(i) = temp + ": " + value.toStdString();
        }

        else {
            lines.push_back(address.toStdString() + ": " + value.toStdString());
        }

        std::ofstream outfile;
        outfile.open(Path::getSetupDir() + "/buffer.yaml");

        foreach (std::string line, lines) {
            outfile << line << endl;
        }

        outfile.close();

        if (value.isEmpty()){
            Backend::bufferSet(address, Backend::grmonGet(address));
        }
    }
}

void Backend::emptyBuffer() {
    std::ofstream file(Path::getSetupDir() + "/buffer.yaml", std::ios::trunc); // Open the file in truncate mode

    if (file.is_open()) {
        file.close();
    } else {
        qDebug() << "Error opening the buffer.yaml file.";
    }
}

QString Backend::checkBuffer(QString address) {
    std::ifstream infile;
    infile.open(Path::getSetupDir() + "/buffer.yaml");
    std::string buffer;

    while (std::getline(infile, buffer)) {
        std::string temp;
        int i;
        for (i = 0; i < buffer.size(); i++) {
            char letter = buffer.at(i);
            if (letter == ':') {
                break;
            }
            temp.push_back(letter);
        }
        if (temp == address.toStdString()) {
            buffer.erase(0, (i + 2));
            infile.close();
            if(buffer == ""){
                Backend::bufferSet(address, Backend::grmonGet(address));
                return Backend::grmonGet(address);
            } else {
            return QString::fromStdString(buffer);
            }
        }
    }

    infile.close();
    return "-1";
}


QString Backend::grmonGet(QString address) {
    processOuts.clear();
    Backend::sendScriptCommand("mem "+address+" 4");
    Backend::scriptProcess.waitForReadyRead();
    QStringList lines = processOuts.split('\n', Qt::SkipEmptyParts);
    QString line = lines[lines.size()-2];
    QString data = line.split('\t')[1];
    QString checkAddress = line.split('\t')[0];
    if (checkAddress==address){
        return "0x"+data;
    } else {
        qDebug()<< "GRMON data read error!";
        return "";
    }
}

void Backend::checkAndSaveAll(QString newFileName) {
    // READ_FILE
    std::ifstream infile;
    infile.open(Path::getSetupDir() + "/config.yaml");
    std::vector<std::string> lines;
    std::string buffer;

    while (getline(infile, buffer)) {
        lines.push_back(buffer);
    }

    infile.close();
    // WRITE_FILE
    std::ofstream outfile;
    outfile.open(Path::getSetupDir() + "/SavedConfigs/" +
                 newFileName.toStdString());
    bool is_firstLine = true;

    foreach (std::string line, lines) {
        outfile << line << endl;
    }

    outfile.close();

    int tempModuleId = globalModuleId;
    QString tempRegId = globalRegId;
    QString tempFieldId = globalFieldId;
    std::string tempConfigFilePath = configFilePath;

    configFilePath = Path::getSetupDir() + "/SavedConfigs/" +
                     newFileName.toStdString();

    QList<QString> moduleList = Backend::getFileList();
    for (int i = 0; i < moduleList.length(); i++) {
        globalModuleId = i;
        Backend::setFilePath(globalModuleId);
        QList<QString> regList = Backend::getRegisterList();
        for (int j = 0; j < regList.length(); j++) {
            globalRegId = QString::number(j);
            QList<QString> fieldList = Backend::getFieldList(globalRegId);
            for (int k = 0; k < fieldList.length(); k++) {
                globalFieldId = QString::number(k);

                QString value = grmonGet(getFieldAddr());

                if (value != "NULL") {
                    qDebug() << moduleList[i] << regList[j] << fieldList[k] << globalModuleId
                             << globalRegId << globalFieldId << getFieldAddr() << value;
                    saveConfig(value, 16);
                }
            }
        }
    }

    globalModuleId = tempModuleId;
    globalRegId = tempRegId;
    globalFieldId = tempFieldId;
    configFilePath = tempConfigFilePath;

    Backend::setDefaultConfigId(newFileName);
}

std::string Backend::deleteNonAlphaNumerical(std::string data) {
    std::string newData;
    foreach (char character, data) {
        if (!((character == ' ') || (character == ':'))) {
            newData.push_back(character);
        }
    }
    return newData;
}

std::vector<std::string> Backend::deleteNonAlphaNumerical_Reg(std::string data) {
    std::vector<std::string> newData;
    newData.push_back("");
    newData.push_back("");

    int switchKeyValue = 0;
    foreach (char character, data) {
        if (character != ' ') {
            if (character == ':') {
                switchKeyValue = 1;
            } else {
                newData.at(switchKeyValue).push_back(character);
            }
        }
    }

    return newData;
}

int Backend::searchNodeVector(std::vector<TreeNode> container, std::string key) {
    for (int i = 0; i < container.size(); ++i) {
        if (container.at(i).name == key) {
            return i;
        }
    }
    return -1;
}

int Backend::getIdByName(std::string component, std::string name) {
    if (component == "module") {
        QList<QString> moduleList = Backend::getFileList();
        for (int i = 0; i < moduleList.length(); ++i) {
            if (moduleList.at(i) == QString::fromStdString((name + ".yaml"))) {
                return i;
            }
        }
    } else if (component == "reg") {
        Backend::setFilePath(globalModuleId);
        QList<QString> regList = Backend::getRegisterList();
        for (int i = 0; i < regList.length(); ++i) {
            if (regList.at(i) == QString::fromStdString(name)) {
                return i;
            }
        }
    } else if (component == "field") {
        QList<QString> fieldList = Backend::getFieldList(globalRegId);
        for (int i = 0; i < fieldList.length(); ++i) {
            if (fieldList.at(i) == QString::fromStdString(name)) {
                return i;
            }
        }
    }

    return -1;
}

QList<QString> Backend::vectorToQList(std::vector<std::string> vector) {
    QList<QString> qlist;

    foreach (std::string item, vector) {
        qlist.append(QString::fromStdString(item));
    }

    return qlist;
}

int Backend::returnPinConfig(QString initSignal) {
    // READ_FILE
    std::ifstream infile;
    infile.open(Path::getSetupDir() + "/pinSlots.yaml");
    std::vector<std::string> lines;
    std::string buffer;

    while (getline(infile, buffer)) {
        lines.push_back(buffer);
    }

    infile.close();
    // READ_FILE

    globalPinConfig.clear();

    for (int i = 0; i < lines.size(); i++) {
        int dotCounter = 0;
        std::vector<std::string> buffer;
        buffer.push_back("0");
        std::string temp;
        for (int j = 2; j < lines.at(i).size(); j++) {
            if (lines.at(i).at(j) == '.') {
                dotCounter++;
                buffer.at(0) = std::to_string(dotCounter);
                buffer.push_back(temp);
                temp.clear();

            } else {
                temp.push_back(lines.at(i).at(j));
                if (j == lines.at(i).size() - 1) {
                    dotCounter++;
                    buffer.at(0) = std::to_string(dotCounter);
                    buffer.push_back(temp);
                    temp.clear();
                }
            }
        }
        globalPinConfig.push_back(Backend::vectorToQList(buffer));
    }

    return globalPinConfig.size();
}

QList<QString> Backend::returnPinConfig(int index) { return globalPinConfig.at(index); }

int Backend::findPinConfig(QString componentType, QString componentId) {
    int componentTypeInt;
    if (componentType.toStdString() == "module") {
        componentTypeInt = 1;
    } else if (componentType.toStdString() == "reg") {
        componentTypeInt = 2;
    } else if (componentType.toStdString() == "field") {
        componentTypeInt = 3;
    } else {
        componentTypeInt = componentType.toInt();
    }

    int foundOn = -1;
    switch (componentTypeInt) {
    case 1: {
        std::string tempModuleName = Backend::getFileList().at(componentId.toInt()).toStdString();
        std::string moduleName;
        foreach (char it, tempModuleName) {
            if (it == '.') {
                break;
            }
            moduleName.push_back(it);
        }

        for (int i = 0; i < Backend::returnPinConfig("init"); i++) {
            if (globalPinConfig.at(i).at(0) == "1") {
                if (globalPinConfig.at(i).at(1).split('\r').at(0) ==
                    QString::fromStdString(moduleName)) {
                    foundOn = i;
                }
            }
        }

        break;
    }
    case 2: {
        std::string tempModuleName = Backend::getFileList().at(globalModuleId).toStdString();
        std::string moduleName;
        foreach (char it, tempModuleName) {
            if (it == '.') {
                break;
            }
            moduleName.push_back(it);
        }

        std::string regName = Backend::getRegisterList().at(componentId.toInt()).toStdString();

        for (int i = 0; i < Backend::returnPinConfig("init"); i++) {
            if (globalPinConfig.at(i).at(0) == "2") {
                if ((globalPinConfig.at(i).at(1) == QString::fromStdString(moduleName)) &&
                    (globalPinConfig.at(i).at(2).split('\r').at(0) ==
                     QString::fromStdString(regName))) {
                    foundOn = i;
                }
            }
        }

        break;
    }
    case 3: {
        std::string tempModuleName = Backend::getFileList().at(globalModuleId).toStdString();
        std::string moduleName;
        foreach (char it, tempModuleName) {
            if (it == '.') {
                break;
            }
            moduleName.push_back(it);
        }

        std::string regName = Backend::getRegisterList().at(globalRegId.toInt()).toStdString();

        std::string fieldName =
            Backend::getFieldList(globalRegId).at(componentId.toInt()).toStdString();

        for (int i = 0; i < Backend::returnPinConfig("init"); i++) {
            if (globalPinConfig.at(i).at(0) == "3") {
                if ((globalPinConfig.at(i).at(1) == QString::fromStdString(moduleName)) &&
                    (globalPinConfig.at(i).at(2) == QString::fromStdString(regName)) &&
                    (globalPinConfig.at(i).at(3).split('\r').at(0) ==
                     QString::fromStdString(fieldName))) {
                    foundOn = i;
                }
            }
        }

        break;
    }
    }

    return foundOn;
}

void Backend::addToPinConfig(QString componentType, QString componentId) {
    int componentTypeInt;
    if (componentType.toStdString() == "module") {
        componentTypeInt = 1;
    } else if (componentType.toStdString() == "reg") {
        componentTypeInt = 2;
    } else if (componentType.toStdString() == "field") {
        componentTypeInt = 3;
    } else {
        componentTypeInt = componentType.toInt();
    }

    int foundOn = Backend::findPinConfig(componentType, componentId);

    if (foundOn == -1) {
        std::string componentPath;
        switch (componentTypeInt) {
        case 1: {
            std::string tempModuleName =
                Backend::getFileList().at(componentId.toInt()).toStdString();
            std::string moduleName;
            foreach (char it, tempModuleName) {
                if (it == '.') {
                    break;
                }
                moduleName.push_back(it);
            }
            componentPath = "- " + moduleName;

            break;
        }
        case 2: {
            std::string tempModuleName = Backend::getFileList().at(globalModuleId).toStdString();
            std::string moduleName;
            foreach (char it, tempModuleName) {
                if (it == '.') {
                    break;
                }
                moduleName.push_back(it);
            }

            std::string regName = Backend::getRegisterList().at(componentId.toInt()).toStdString();
            componentPath = "- " + moduleName + '.' + regName;

            break;
        }
        case 3: {
            std::string tempModuleName = Backend::getFileList().at(globalModuleId).toStdString();
            std::string moduleName;
            foreach (char it, tempModuleName) {
                if (it == '.') {
                    break;
                }
                moduleName.push_back(it);
            }

            std::string regName = Backend::getRegisterList().at(globalRegId.toInt()).toStdString();

            std::string fieldName =
                Backend::getFieldList(globalRegId).at(componentId.toInt()).toStdString();

            componentPath = "- " + moduleName + '.' + regName + '.' + fieldName;

            break;
        }
        }

        std::ofstream outFile;
        outFile.open(Path::getSetupDir() + "/pinSlots.yaml",
                     std::ios::app);
        if (outFile.is_open()) {
            // Write the line at the end of the file
            outFile << componentPath << std::endl;

            outFile.close();
        } else {
            qDebug() << "Failed to open the pinBoard config file.";
        }
    }

    else {
        qDebug() << "COMPONENT IS ALREADY IN THE PIN LIST";
    }
}

void Backend::removeFromPinConfig(QString componentType, QString componentId) {
    int lineNumber = Backend::findPinConfig(componentType, componentId);
    if (lineNumber != -1) {
        std::string filename =
            Path::getSetupDir() + "/pinSlots.yaml";
        std::ifstream inputFile(filename);
        std::vector<std::string> lines;

        if (inputFile.is_open()) {
            std::string line;

            // Read all lines from the file
            while (std::getline(inputFile, line)) {
                lines.push_back(line);
            }

            inputFile.close();

            // Check if the line number is valid
            if (lineNumber >= 0 && lineNumber <= lines.size()) {
                // Remove the line from the vector
                lines.erase(lines.begin() + lineNumber);

                std::ofstream outputFile(filename);

                if (outputFile.is_open()) {
                    // Write the modified content back to the file
                    for (const auto& line : lines) {
                        outputFile << line << std::endl;
                    }

                    outputFile.close();
                } else {
                    qDebug() << "pinConfig.yaml: Failed to open the file for writing.";
                }
            } else {
                qDebug() << "pinConfig.yaml: Invalid line number.";
            }
        } else {
            qDebug() << "pinConfig.yaml: Failed to open the file for reading.";
        }
    }
}

void Backend::removeFromPinConfig(int lineNumber) {
    if (lineNumber != -1) {
        std::string filename =
            Path::getSetupDir() + "/pinSlots.yaml";
        std::ifstream inputFile(filename);
        std::vector<std::string> lines;

        if (inputFile.is_open()) {
            std::string line;

            // Read all lines from the file
            while (std::getline(inputFile, line)) {
                lines.push_back(line);
            }

            inputFile.close();

            // Check if the line number is valid
            if (lineNumber >= 0 && lineNumber <= lines.size()) {
                // Remove the line from the vector
                lines.erase(lines.begin() + lineNumber);

                std::ofstream outputFile(filename);

                if (outputFile.is_open()) {
                    // Write the modified content back to the file
                    for (const auto& line : lines) {
                        outputFile << line << std::endl;
                    }

                    outputFile.close();
                } else {
                    qDebug() << "pinConfig.yaml: Failed to open the file for writing.";
                }
            } else {
                qDebug() << "pinConfig.yaml: Invalid line number.";
            }
        } else {
            qDebug() << "pinConfig.yaml: Failed to open the file for reading.";
        }
    }
}

//SCRIPT CONNECTION

bool Backend::launchScript(QString scriptName){
    if(Backend::startScript(QString::fromStdString(Path::getSetupDir()+"TargetMocks/grmon_imitator/python_executables/")+scriptName+"/"+scriptName)){
        Backend::setStartUp(true);
        emit Backend::consoleLoading();
        qDebug()<<"Script launched.";
        return true;
    } else {
        qDebug()<<"Script launch error!";
        return false;
    }
}

void Backend::processOutput() {
    QString data = Backend::scriptProcess.readAllStandardOutput();
    if(data!="\n"){
//        qDebug()<<qPrintable(data);
        processOuts += qPrintable(data);
        emit updateConsoleMonitor(processOuts);
        if(Backend::isStartUp){
            if(Backend::endsWithGrmonX(data.toStdString())){
                emit Backend::consoleReady();
                Backend::setStartUp(false);
            }
        }
    }
//HANDLE NEWLINE-ONLY OUTPUTS!!!
//    std::cout<<Backend::scriptProcess.readAllStandardOutput().toStdString();
    // Process the data as needed
}

bool Backend::startScript(const QString& scriptPath) {
    // Start the Bash script and configure the process
    if(QSysInfo::kernelType()=="linux"){
//        Backend::scriptProcess.setProgram("bash");
//        QStringList args;
//        args << scriptPath;
//        Backend::scriptProcess.setArguments(args);

        Backend::scriptProcess.setWorkingDirectory(QFileInfo(scriptPath).path());
        Backend::scriptProcess.setProgram("./"+QFileInfo(scriptPath).fileName());
    } else if(QSysInfo::kernelType()=="winnt") {
        Backend::scriptProcess.setProgram("cmd.exe");

        QStringList args;
        args << scriptPath;
        Backend::scriptProcess.setArguments(args);
    } else {
        qDebug() << "Failed to start the script.(Unknown kernel type)";
        return false;
    }


    // Configure the process for reading and writing
    Backend::scriptProcess.setProcessChannelMode(QProcess::SeparateChannels);
    Backend::scriptProcess.setReadChannel(QProcess::StandardOutput);
    Backend::scriptProcess.start();  // Start the process

    // Check if the process started successfully
    if (!Backend::scriptProcess.waitForStarted()) {
        qDebug() << "Failed to start the script.";
        return false;
    }

    return true;
}

// Function to send a command to the running script
void Backend::sendScriptCommand(const QString &command) {
    if (Backend::scriptProcess.state() == QProcess::Running) {
        Backend::scriptProcess.write(command.toUtf8());
        Backend::scriptProcess.write("\n");  // You might need to add a newline character
        Backend::scriptProcess.waitForBytesWritten();  // Wait for the data to be written to the process
        emit Backend::updateConsoleMonitor(qPrintable(command+'\n'));
    }
}

// Function to stop the script
void Backend::stopScript() {
    if (Backend::scriptProcess.state() == QProcess::Running) {
        Backend::scriptProcess.terminate();
        Backend::scriptProcess.waitForFinished();
        qDebug() << "Script stopped.";
    } else {
        qDebug() << "Script is not running.";
    }
}

bool Backend::returnScriptState() {
    if (Backend::scriptProcess.state() == QProcess::Running) {
        return true;
    }
    return false;
}

bool Backend::endsWithGrmonX(const std::string& input) {
    if (input.length() < 7) {return false;}
    if (input.substr(input.length() - 7).erase(5,1) == "grmon>") {return true;}
    return false;
}

void Backend::setStartUp(bool value) {Backend::isStartUp = value;}

void Backend::saveConsoleLog(QString content) {
    auto now = std::chrono::system_clock::now();
    auto timestamp = std::chrono::system_clock::to_time_t(now);
    std::string timestampStr = std::to_string(timestamp);

    std::string filePath = Path::getSetupDir() + "../Logs/consoleLog_" + timestampStr + ".txt";

    std::ofstream file(filePath);

    if (file.is_open()) {
        file << content.toStdString();
        file.close();
        qDebug() << "File saved successfully: " << QString::fromStdString(filePath);
    } else {
        qDebug() << "Error: Unable to open the file for writing.";
    }
}
