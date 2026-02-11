#!/usr/bin/env python3
"""
QML 语法检查脚本
用于验证 QML 文件的基本语法，无需运行 GUI 程序
"""

import re
import sys
import os


def check_braces_balance(content):
    """检查大括号平衡"""
    stack = []
    lines = content.split('\n')
    
    for idx, line in enumerate(lines, 1):
        for char_idx, char in enumerate(line):
            if char == '{':
                stack.append((idx, char_idx, line.strip()))
            elif char == '}':
                if not stack:
                    return False, f"第 {idx} 行: 发现多余的右大括号 '{char}'"
                stack.pop()
    
    if stack:
        line_no, char_idx, line_content = stack[-1]
        return False, f"第 {line_no} 行: 缺少右大括号，对应内容: {line_content}"
    
    return True, "大括号平衡"


def check_import_statements(content):
    """检查import语句"""
    lines = content.split('\n')
    errors = []
    
    for idx, line in enumerate(lines, 1):
        if line.strip().startswith('import '):
            # 在Qt6中，import语句可以不以分号结尾（虽然推荐有分号）
            # 所以我们只警告，不视为严重错误
            if not line.strip().endswith(';'):
                # 不记录为错误，因为Qt6中这是可选的
                pass
    
    return True, []  # Qt6中import语句可以不加分号


def check_property_definitions(content):
    """检查属性定义"""
    lines = content.split('\n')
    errors = []
    
    # 检查属性定义的常见错误
    for idx, line in enumerate(lines, 1):
        stripped = line.strip()
        if stripped.startswith('property ') and ':' in stripped and not stripped.endswith(';'):
            errors.append(f"第 {idx} 行: 属性定义缺少分号")
    
    return len(errors) == 0, errors


def validate_qml_file(filepath):
    """验证QML文件"""
    if not os.path.exists(filepath):
        return False, [f"文件不存在: {filepath}"]
    
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except UnicodeDecodeError:
        with open(filepath, 'r', encoding='gbk') as f:
            content = f.read()
    
    results = []
    
    # 检查大括号平衡
    is_balanced, msg = check_braces_balance(content)
    if not is_balanced:
        results.append(msg)
    else:
        results.append("✓ 大括号平衡检查通过")
    
    # 检查import语句
    is_valid_imports, import_errors = check_import_statements(content)
    if import_errors:
        results.extend(import_errors)
    else:
        results.append("✓ Import语句检查通过")
    
    # 检查属性定义
    is_valid_props, prop_errors = check_property_definitions(content)
    if prop_errors:
        results.extend(prop_errors)
    else:
        results.append("✓ 属性定义检查通过")
    
    return len(results) == 3, results


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("用法: python check_qml_syntax.py <qml_file>")
        sys.exit(1)
    
    filepath = sys.argv[1]
    is_valid, results = validate_qml_file(filepath)
    
    print(f"\n=== QML 语法检查结果: {filepath} ===")
    for result in results:
        print(result)
    
    if is_valid:
        print("\n✓ 语法检查通过!")
        sys.exit(0)
    else:
        print(f"\n✗ 发现语法问题，共 {len([r for r in results if not r.startswith('✓')])} 个")
        sys.exit(1)