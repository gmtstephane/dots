local M = {}

-- Dependency on nvim-treesitter
local ts = vim.treesitter
local ts_utils = require "nvim-treesitter.ts_utils"
local ts_parsers = require "nvim-treesitter.parsers"

function M.get_current_package()
  local parser = ts.get_parser(0, "go")
  local tree = parser:parse()[1]
  local root = tree:root()

  -- Look for "package_clause" node
  for node in root:iter_children() do
    if node:type() == "package_clause" then
      for child in node:iter_children() do
        if child:type() == "package_identifier" then
          return ts.get_node_text(child, 0)
        end
      end
    end
  end

  return nil
end
-- Function to get the struct under cursor
function M.get_struct_under_cursor()
  -- Ensure go parser is available
  if not ts_parsers.has_parser "go" then
    vim.notify("Go parser not available. Make sure Treesitter is installed correctly.", vim.log.levels.ERROR)
    return nil
  end

  -- Get current node under cursor
  local node = ts_utils.get_node_at_cursor()
  if not node then
    return nil
  end

  -- Navigate up to find the struct type declaration
  while node and node:type() ~= "type_declaration" do
    node = node:parent()
  end

  if not node then
    vim.notify("No struct type declaration found under cursor", vim.log.levels.WARN)
    return nil
  end

  return node
end

-- Extract struct info from node
function M.extract_struct_info(node)
  if not node then
    return nil
  end

  local struct_info = {
    name = "",
    fields = {},
  }

  -- Find the type spec and struct name
  local type_spec = nil
  for child, _ in node:iter_children() do
    if child:type() == "type_spec" then
      type_spec = child
      break
    end
  end

  if not type_spec then
    return nil
  end

  -- Get struct name
  for child, _ in type_spec:iter_children() do
    if child:type() == "type_identifier" then
      struct_info.name = vim.treesitter.get_node_text(child, 0)
    end
  end

  -- Get struct type (to find the fields)
  local struct_type = nil
  for child, _ in type_spec:iter_children() do
    if child:type() == "struct_type" then
      struct_type = child
      break
    end
  end

  if not struct_type then
    return nil
  end

  -- Find field declarations
  for child, _ in struct_type:iter_children() do
    if child:type() == "field_declaration_list" then
      for field_node, _ in child:iter_children() do
        if field_node:type() == "field_declaration" then
          local field = {
            name = "",
            type = "",
          }

          -- Extract field name and type
          for field_child, _ in field_node:iter_children() do
            if field_child:type() == "field_identifier" then
              field.name = vim.treesitter.get_node_text(field_child, 0)
            elseif
              field_child:type() == "type_identifier"
              or field_child:type() == "qualified_type"
              or field_child:type() == "pointer_type"
              or field_child:type() == "array_type"
              or field_child:type() == "map_type"
              or field_child:type() == "slice_type"
              or field_child:type() == "interface_type"
              or field_child:type() == "struct_type"
            then
              field.type = vim.treesitter.get_node_text(field_child, 0)
            end
          end

          if field.name ~= "" then
            table.insert(struct_info.fields, field)
          end
        end
      end
    end
  end

  return struct_info
end

-- Debug function to test the extractor
function M.debug_struct_info()
  local node = M.get_struct_under_cursor()
  if not node then
    print "No struct found under cursor"
    return
  end

  print("Node type:", node:type())

  local struct_info = M.extract_struct_info(node)
  if not struct_info then
    print "Failed to extract struct information"
    return
  end

  print("\nStruct name:", struct_info.name)
  print "\nFields:"
  for i, field in ipairs(struct_info.fields) do
    print(i .. ". " .. field.name .. " (" .. field.type .. ")")
  end

  -- Print the raw node text for debugging
  print "\nRaw node text:"
  print(vim.treesitter.get_node_text(node, 0))
end

-- Generate the copy struct code
function M.generate_copy_struct(struct_info)
  if not struct_info or not struct_info.name then
    return nil
  end

  local copy_name = struct_info.name
  local source_name = struct_info.name
  local lines = {}
  local package_name = M.get_current_package()
  -- Generate the struct declaration
  table.insert(lines, "")
  table.insert(lines, "")
  table.insert(lines, "type " .. copy_name .. " struct {")
  for _, field in ipairs(struct_info.fields) do
    table.insert(lines, "\t" .. field.name .. " " .. field.type)
  end
  table.insert(lines, "}")
  table.insert(lines, "")

  -- Generate the constructor
  table.insert(
    lines,
    "func New" .. copy_name .. "(c " .. package_name .. "." .. source_name .. ") " .. copy_name .. " {"
  )
  table.insert(lines, "\treturn " .. copy_name .. "{")
  for _, field in ipairs(struct_info.fields) do
    table.insert(lines, "\t\t" .. field.name .. ": c." .. field.name .. ",")
  end
  table.insert(lines, "\t}")
  table.insert(lines, "}")
  table.insert(lines, "")

  -- Generate the Model() method
  table.insert(lines, "func (u " .. copy_name .. ") Model() " .. source_name .. " {")
  table.insert(lines, "\treturn " .. source_name .. "{")
  for _, field in ipairs(struct_info.fields) do
    table.insert(lines, "\t\t" .. field.name .. ": u." .. field.name .. ",")
  end
  table.insert(lines, "\t}")
  table.insert(lines, "}")

  return table.concat(lines, "\n")
end

-- Function to generate copy struct and copy to a register
function M.generate_and_copy_to_register(register)
  register = register or '"' -- Default to the unnamed register

  local node = M.get_struct_under_cursor()
  if not node then
    vim.notify("No struct found under cursor", vim.log.levels.ERROR)
    return
  end

  local struct_info = M.extract_struct_info(node)
  if not struct_info then
    vim.notify("Failed to extract struct information", vim.log.levels.ERROR)
    return
  end

  local copy_code = M.generate_copy_struct(struct_info)
  if not copy_code then
    vim.notify("Failed to generate copy struct code", vim.log.levels.ERROR)
    return
  end

  -- Set the generated code to the specified register
  vim.fn.setreg(register, copy_code)
  print(copy_code)
  vim.notify("Copy struct code generated and copied to register " .. register, vim.log.levels.INFO)
end
return M
