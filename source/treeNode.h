#ifndef TREENODE_H
#define TREENODE_H

#include <string>
#include <utility>
#include <vector>

class TreeNode {
   public:
    std::string name;
    int degree;
    std::string value;
    TreeNode *parent;
    // WRITE BRIEF
    TreeNode(std::string nameConstruct, int degreeConstruct)
        : name(std::move(nameConstruct)), degree(degreeConstruct), parent(nullptr) {}
    // WRITE BRIEF
    TreeNode(TreeNode *parentConstruct, std::string nameConstruct, int degreeConstruct)
        : name(std::move(nameConstruct)), degree(degreeConstruct), parent(parentConstruct) {}
    // WRITE BRIEF
    TreeNode(std::string nameConstruct, int degreeConstruct, std::string valueConstruct)
        : name(std::move(nameConstruct)),
          degree(degreeConstruct),
          value(std::move(valueConstruct)),
          parent(nullptr) {}
    // WRITE BRIEF
    TreeNode(TreeNode *parentConstruct, std::string nameConstruct, int degreeConstruct,
             std::string valueConstruct)
        : name(std::move(nameConstruct)),
          degree(degreeConstruct),
          value(std::move(valueConstruct)),
          parent(parentConstruct) {}
    std::vector<TreeNode> children;
    void addChild(TreeNode child) { children.push_back(child); }
};

#endif  // TREENODE_H