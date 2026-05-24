// Resolves split OpenAPI YAML files into a single JSON object for swagger-ui-express.
// Reads docs/openapi/openapi.yaml and follows $ref references.

import yaml from "js-yaml";
import fs from "fs";
import path from "path";

// Resolved from the backend project root (where `bun run` is executed)
const ROOT = path.resolve(process.cwd(), "openapi");

// Cache loaded files by absolute path
const fileCache = new Map<string, any>();

function loadYaml(filePath: string): any {
  if (fileCache.has(filePath)) return fileCache.get(filePath);
  const raw = fs.readFileSync(filePath, "utf-8");
  const doc = yaml.load(raw) as any;
  fileCache.set(filePath, doc);
  return doc;
}

function isRefNode(obj: any): obj is { $ref: string } {
  return (
    obj !== null &&
    typeof obj === "object" &&
    typeof obj.$ref === "string" &&
    Object.keys(obj).length === 1
  );
}

// Follow a JSON Pointer path (e.g., "/components/schemas/Error")
function followPointer(root: any, pointer: string): any {
  if (!pointer || pointer === "/") return root;
  const segments = pointer.split("/").filter(Boolean);
  let node = root;
  for (const seg of segments) {
    node = node[seg];
    if (node === undefined) {
      throw new Error(`JSON Pointer segment "${seg}" not found in "${pointer}"`);
    }
  }
  return node;
}

function resolveRefs(obj: any, currentFile: string): any {
  if (obj === null || typeof obj !== "object") return obj;

  if (isRefNode(obj)) {
    const [filePart, pointerPart] = obj.$ref.split("#");
    const pointer = pointerPart ?? "/";
    const filePath = filePart
      ? path.resolve(path.dirname(currentFile), filePart)
      : currentFile;

    const doc = loadYaml(filePath);
    const target = followPointer(doc, pointer);
    return resolveRefs(target, filePath);
  }

  if (Array.isArray(obj)) {
    return obj.map((item) => resolveRefs(item, currentFile));
  }

  const result: Record<string, any> = {};
  for (const [key, value] of Object.entries(obj)) {
    result[key] = resolveRefs(value, currentFile);
  }
  return result;
}

// Return a fully resolved OpenAPI document as a plain JS object.
export function buildOpenApiDoc(): Record<string, unknown> {
  const rootPath = path.join(ROOT, "openapi.yaml");
  const root = loadYaml(rootPath);
  return resolveRefs(root, rootPath) as Record<string, unknown>;
}
