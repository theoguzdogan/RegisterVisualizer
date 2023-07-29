#include "yaml.h"

using std::string;
using std::stringstream;
using std::vector;
using YAML::const_iterator;
using YAML::LoadFile;
using YAML::Node;

Node Yaml::getNodeByKey(const string &yamlFilePath, const string &key) {
    Node rootNode = LoadFile(yamlFilePath);

    return searchNodeByKey(rootNode, key).at(0);
}

Node Yaml::getNodeByKey(const string &yamlFilePath, const string &key, const string &value) {
    Node rootNode = LoadFile(yamlFilePath);

    return searchNodeByKey(rootNode, key, value).at(0);
}

vector<Node> Yaml::getNodeListByKey(const string &yamlFilePath, const string &key) {
    Node rootNode = LoadFile(yamlFilePath);

    return searchNodeByKey(rootNode, key);
}

vector<Node> Yaml::getNodeListByKey(const string &yamlFilePath, const string &key,
                                    const string &value) {
    Node rootNode = LoadFile(yamlFilePath);

    return searchNodeByKey(rootNode, key, value);
}

Node Yaml::getNodeByPath(const string &yamlFilePath, const string &path) {
    Node rootNode = LoadFile(yamlFilePath);
    vector<string> pathOrder = splitPath(path, '.');

    return searchByNodePath(rootNode, pathOrder).at(0);
}

string Yaml::getValue(const Node &node, const string &key) {
    if (node.IsScalar()) {
        return node.as<string>();
    }

    if(node[key]) {
        return node[key].as<string>();
    }

    return searchValue(node, key).at(0);
}

string Yaml::getValue(const std::string &yamlFilePath, const std::string &key) {
    Node rootNode = LoadFile(yamlFilePath);

    return searchValue(rootNode, key).at(0);
}

vector<string> Yaml::getValueList(const Node &node, const string &key) {
    vector<string> valueList = {};

    if (node.IsScalar()) {
        valueList.push_back(node.as<string>());
        return valueList;
    }

    return searchValue(node, key);
}

vector<string> Yaml::getValueList(const std::string &yamlFilePath, const std::string &key) {
    Node rootNode = LoadFile(yamlFilePath);

    return searchValue(rootNode, key);
}

vector<Node> Yaml::getSeconds(const Node &node, const string &key) {
    vector<Node> resultNodes;
    
    for (const_iterator it = node.begin(); it != node.end(); ++it) {
        if (it->first.as<string>() == key) {
            resultNodes.push_back(it->second);
        }
    }
    
    return resultNodes;
}

vector<Node> Yaml::searchByNodePath(const Node node, vector<string> pathOrder) {
    if (pathOrder.size() == 1) {
        vector<Node> temp = Yaml::searchNodeByKey(node, pathOrder.at(0));
        return Yaml::getSeconds(temp.at(0), pathOrder.at(0));
    }

    vector<Node> resultNode = Yaml::searchNodeByKey(node, pathOrder.at(0));
    pathOrder.erase(pathOrder.begin());
    return Yaml::searchByNodePath(resultNode.at(0), pathOrder);
}

vector<Node> Yaml::searchNodeByKey(const Node node, const string &key, const string &value) {
    vector<Node> resultList;

    if (node.IsSequence()) {
        for (const_iterator it = node.begin(); it != node.end(); ++it) {
            vector<Node> temp = searchNodeByKey(*it, key, value);
            resultList.insert(resultList.end(), temp.begin(), temp.end());
        }
    } else if (node.IsMap()) {
        for (const_iterator it = node.begin(); it != node.end(); ++it) {
            if (it->first.as<string>() == key and it->second.as<string>() == value) {
                resultList.push_back(node);
            } else {
                vector<Node> temp = searchNodeByKey(it->second, key, value);
                resultList.insert(resultList.end(), temp.begin(), temp.end());
            }
        }
    }

    return resultList;
}

vector<Node> Yaml::searchNodeByKey(const Node node, const string &key) {
    vector<Node> resultList;

    if (node.IsSequence()) {
        for (const_iterator it = node.begin(); it != node.end(); ++it) {
            vector<Node> temp = searchNodeByKey(*it, key);
            resultList.insert(resultList.end(), temp.begin(), temp.end());
        }
    } else if (node.IsMap()) {
        for (const_iterator it = node.begin(); it != node.end(); ++it) {
            if (it->first.as<string>() == key) {
                resultList.push_back(node);
            } else {
                vector<Node> temp = searchNodeByKey(it->second, key);
                resultList.insert(resultList.end(), temp.begin(), temp.end());
            }
        }
    }
    return resultList;
}

vector<string> Yaml::searchValue(const Node &node, const string &key) {
    vector<string> resultList;

    if (node.IsSequence()) {
        for (const_iterator it = node.begin(); it != node.end(); ++it) {
            vector<string> temp = searchValue(*it, key);
            resultList.insert(resultList.end(), temp.begin(), temp.end());
        }
    } else if (node.IsMap()) {
        for (const_iterator it = node.begin(); it != node.end(); ++it) {
            if (it->first.as<string>() == key and it->second.IsScalar()) {
                resultList.push_back(it->second.as<string>());
            } else {
                vector<string> temp = searchValue(it->second, key);
                resultList.insert(resultList.end(), temp.begin(), temp.end());
            }
        }
    }

    return resultList;
}

vector<string> Yaml::splitPath(const string &path, char delimiter) {
    vector<string> pathVector;
    stringstream ss(path);
    string item;

    while (getline(ss, item, delimiter)) {
        pathVector.push_back(item);
    }

    return pathVector;
}