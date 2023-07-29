#ifndef YAML_H
#define YAML_H

#include <yaml-cpp/yaml.h>

/**
 * A class for yaml operations.
 */
class Yaml {
   public:
    Yaml(const Yaml &) = delete;
    Yaml &operator=(Yaml const &) = delete;
    Yaml(Yaml &&) = delete;
    Yaml &operator=(Yaml &&) = delete;

    /**
     * @brief Get the yaml node in the given yaml file with the given key.
     *
     * @param    yamlFilePath        The path where the yaml file is located.
     * @param    key                 The yaml node key the desired node must have.
     * @return   YAML::Node
     */
    static YAML::Node getNodeByKey(const std::string &yamlFilePath, const std::string &key);

    /**
     * @brief Get the yaml node in the given yaml file with the given key and value.
     *
     * @param    yamlFilePath        The path where the yaml file is located.
     * @param    key                 The yaml node key the desired node must have.
     * @param    value               The value to the key the desired node must have.
     * @return   YAML::Node
     */
    static YAML::Node getNodeByKey(const std::string &yamlFilePath, const std::string &key,
                                   const std::string &value);

    /**
     * @brief Get the yaml node list in the given yaml file with the given key.
     *
     * @param    yamlFilePath        The path where the yaml file is located.
     * @param    key                 The yaml node key the desired nodes must have.
     * @return   std::vector<YAML::Node>
     */
    static std::vector<YAML::Node> getNodeListByKey(const std::string &yamlFilePath,
                                                    const std::string &key);

    /**
     * @brief Get the yaml node list in the given yaml file with the given key and value.
     *
     * @param    yamlFilePath        The path where the yaml file is located.
     * @param    key                 The yaml node key the desired nodes must have.
     * @param    value               The value to the key the desired node must have.
     * @return   std::vector<YAML::Node>
     */
    static std::vector<YAML::Node> getNodeListByKey(const std::string &yamlFilePath,
                                                    const std::string &key,
                                                    const std::string &value);

    /**
     * @brief Get the yaml node in the given yaml file with the given node path.
     *
     * @param    yamlFilePath        The path where the yaml file is located.
     * @param    path                The path to the desired node. Nodes must be separated by a '.'
     *                               (...grandParentNode.parentNode.desiredNode)
     * @return   YAML::Node
     */
    static YAML::Node getNodeByPath(const std::string &yamlFilePath, const std::string &path);

    /**
     * @brief Get the value of the given yaml node with the given key.
     *
     * @param    node                The yaml node to retrieve the value from.
     * @param    key                 The yaml node key the desired node must have.
     * @return   std::string
     */
    static std::string getValue(const YAML::Node &node, const std::string &key);

    /**
     * @brief Get the value of the yaml node in the given yaml file with the given key.
     *
     * @param    yamlFilePath        The path where the yaml file is located.
     * @param    key                 The yaml node key the desired node must have.
     * @return   std::string
     */
    static std::string getValue(const std::string &yamlFilePath, const std::string &key);

    /**
     * @brief Get the value list of the given yaml node with the given key.
     *
     * @param    node                The yaml node to retrieve the values from.
     * @param    key                 The yaml node key the desired node must have.
     * @return   std::vector<std::string>
     */
    static std::vector<std::string> getValueList(const YAML::Node &node, const std::string &key);

    /**
     * @brief Get the value list of the yaml node in the given yaml file with the given key.
     *
     * @param    yamlFilePath        The path where the yaml file is located.
     * @param    key                 The yaml node key the desired node must have.
     * @return   std::vector<std::string>
     */
    static std::vector<std::string> getValueList(const std::string &yamlFilePath,
                                                 const std::string &key);

    /**
     * @brief Get the seconds of a given node.
     *
     * @param node                   The yaml node to retrieve the values from.
     * @param key                    The yaml node key the desired node must have.
     * @return std::vector<YAML::Node>
     */
    static std::vector<YAML::Node> getSeconds(const YAML::Node &node, const std::string &key);

    /**
     * Searches a YAML node for a key-value pair.
     *
     * @param node The node to search.
     * @param key The key to search for.
     * @param value The value to search for.
     *
     * @returns A vector of nodes that match the key-value pair.
     */
    static std::vector<YAML::Node> searchNodeByKey(YAML::Node node, const std::string &key,
                                                   const std::string &value);

    /**
     * Searches for a node in a YAML document by key.
     *
     * @param node The YAML document to search.
     * @param key The key to search for.
     *
     * @returns A vector of nodes that match the key.
     */
    static std::vector<YAML::Node> searchNodeByKey(YAML::Node node, const std::string &key);

    /**
     * Searches for a value in a YAML node.
     *
     * @param node The node to search.
     * @param key The key to search for.
     *
     * @returns A list of values found.
     */
    static std::vector<std::string> searchValue(const YAML::Node &node, const std::string &key);

   private:
    Yaml() = default;
    ~Yaml() = default;

    /**
     * Searches for a node in a YAML document by a path of node names.
     *
     * @param node The root node of the YAML document.
     * @param pathOrder The path of node names to search for.
     *
     * @returns The node found by the path, or an empty node if the path is not found.
     */
    static std::vector<YAML::Node> searchByNodePath(YAML::Node node,
                                                    std::vector<std::string> pathOrder);

    /**
     * Splits a path into a vector of strings.
     *
     * @param path The path to split.
     * @param delimiter The delimiter to split the path on.
     *
     * @returns A vector of strings representing the path split by the delimiter.
     */
    static std::vector<std::string> splitPath(const std::string &path, char delimiter);
};

#endif  // YAML_H
