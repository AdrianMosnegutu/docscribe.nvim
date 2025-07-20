--- @module "docscribe.prompt_templates"
--- Central hub for all prompt templates.

local M = {
    c_template = require("docscribe.prompt_templates.c"),
    cpp_template = require("docscribe.prompt_templates.cpp"),
    default_template = require("docscribe.prompt_templates.default"),
    java_template = require("docscribe.prompt_templates.java"),
    javascript_template = require("docscribe.prompt_templates.javascript"),
    lua_template = require("docscribe.prompt_templates.lua"),
    python_template = require("docscribe.prompt_templates.python"),
    typescript_template = require("docscribe.prompt_templates.typescript"),
}

return M
