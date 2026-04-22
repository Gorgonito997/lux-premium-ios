#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
export_project_context.py

Genera un archivo de contexto legible por IA a partir de un proyecto
(Android, iOS, backend, Firebase, etc.), pensado para pegarlo o subirlo
a ChatGPT/Codex y pedir prompts o ayuda técnica con el máximo contexto.

Uso:
    python export_project_context.py /ruta/al/proyecto

Opcional:
    python export_project_context.py /ruta/al/proyecto -o contexto_luxpremium.txt
    python export_project_context.py /ruta/al/proyecto --max-file-kb 300 --max-total-mb 20

Qué incluye:
- árbol resumido del proyecto
- archivos clave completos (si son texto y no demasiado grandes)
- archivos de configuración prioritarios
- exclusión automática de binarios, builds, Pods, node_modules, etc.
- cabeceras claras para que una IA lo interprete mejor

Consejo:
- Ejecuta este script en la raíz del proyecto.
- Luego súbeme el .txt generado y ya te preparo prompts precisos para Codex.
"""

from __future__ import annotations

import argparse
import fnmatch
import os
from pathlib import Path
import sys
from typing import Iterable


TEXT_EXTENSIONS = {
    ".py", ".kt", ".kts", ".java", ".swift", ".m", ".mm", ".h",
    ".c", ".cpp", ".cc", ".hpp", ".cs",
    ".js", ".ts", ".tsx", ".jsx",
    ".json", ".jsonc", ".yaml", ".yml", ".toml", ".ini", ".cfg",
    ".xml", ".plist", ".pbxproj", ".xcconfig", ".entitlements",
    ".gradle", ".properties", ".md", ".txt", ".sql", ".sh", ".bash",
    ".zsh", ".dart", ".rb", ".env", ".gitignore", ".gitattributes",
    ".html", ".css", ".scss", ".proto"
}

PRIORITY_FILENAMES = {
    "pubspec.yaml",
    "package.json",
    "package-lock.json",
    "yarn.lock",
    "pnpm-lock.yaml",
    "Podfile",
    "Podfile.lock",
    "Gemfile",
    "Gemfile.lock",
    "Cartfile",
    "Cartfile.resolved",
    "build.gradle",
    "build.gradle.kts",
    "settings.gradle",
    "settings.gradle.kts",
    "gradle.properties",
    "local.properties",
    "AndroidManifest.xml",
    "Info.plist",
    "project.pbxproj",
    "GoogleService-Info.plist",
    "google-services.json",
    "firebase.json",
    ".firebaserc",
    "appsettings.json",
    "requirements.txt",
    "README.md",
    ".env",
    ".env.local",
    ".env.production",
    ".env.development",
}

PRIORITY_PATH_PATTERNS = [
    "ios/*",
    "ios/**/*",
    "android/*",
    "android/**/*",
    "app/*",
    "app/**/*",
    "src/*",
    "src/**/*",
    "lib/*",
    "lib/**/*",
    "fastlane/*",
    "fastlane/**/*",
    "functions/*",
    "functions/**/*",
    "backend/*",
    "backend/**/*",
    "api/*",
    "api/**/*",
    "*.xcodeproj/project.pbxproj",
    "*.xcworkspace/*",
]

EXCLUDE_DIRS = {
    ".git", ".idea", ".vscode", ".gradle", ".dart_tool",
    "node_modules", "Pods", "Carthage", "DerivedData",
    "build", "dist", "out", "target", "bin", "obj",
    ".next", ".nuxt", ".expo", ".vercel", ".turbo",
    "__pycache__", ".pytest_cache", ".mypy_cache",
    ".DS_Store"
}

EXCLUDE_FILE_PATTERNS = [
    "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.bmp", "*.ico", "*.icns",
    "*.pdf", "*.mp4", "*.mov", "*.avi", "*.mkv",
    "*.zip", "*.rar", "*.7z", "*.tar", "*.gz",
    "*.keystore", "*.jks", "*.p12", "*.mobileprovision",
    "*.db", "*.sqlite", "*.sqlite3",
    "*.aab", "*.apk", "*.ipa",
    "*.xcarchive", "*.framework", "*.xcframework",
    "*.so", "*.dll", "*.dylib", "*.o", "*.class", "*.jar",
    "*.ttf", "*.otf", "*.woff", "*.woff2",
]

SECRET_HINTS = [
    "api_key", "apikey", "secret", "token", "client_secret", "private_key",
    "password", "passwd", "pwd", "access_key", "auth", "bearer"
]


def is_probably_text_file(path: Path) -> bool:
    ext = path.suffix.lower()
    if ext in TEXT_EXTENSIONS:
        return True
    if path.name in PRIORITY_FILENAMES:
        return True
    if ext == "":
        if path.name.startswith(".env"):
            return True
    return False


def matches_any_pattern(text: str, patterns: Iterable[str]) -> bool:
    return any(fnmatch.fnmatch(text, p) for p in patterns)


def should_exclude(path: Path, root: Path) -> bool:
    rel = path.relative_to(root).as_posix()

    for part in path.parts:
        if part in EXCLUDE_DIRS:
            return True

    if matches_any_pattern(path.name, EXCLUDE_FILE_PATTERNS):
        return True
    if matches_any_pattern(rel, EXCLUDE_FILE_PATTERNS):
        return True

    return False


def safe_read_text(path: Path) -> str | None:
    encodings = ("utf-8", "utf-8-sig", "latin-1")
    for enc in encodings:
        try:
            return path.read_text(encoding=enc)
        except UnicodeDecodeError:
            continue
        except Exception:
            return None
    return None


def mask_secrets(text: str) -> str:
    """
    Enmascara de forma simple líneas sospechosas con secretos.
    No es perfecto, pero evita filtrar credenciales por accidente.
    """
    out_lines = []
    for line in text.splitlines():
        lower = line.lower()
        if any(hint in lower for hint in SECRET_HINTS):
            if "=" in line:
                key, _, _ = line.partition("=")
                out_lines.append(f"{key}=***MASKED***")
                continue
            if ":" in line:
                key, _, _ = line.partition(":")
                out_lines.append(f"{key}: ***MASKED***")
                continue
        out_lines.append(line)
    return "\n".join(out_lines)


def build_tree(root: Path, max_depth: int = 5) -> str:
    lines: list[str] = [root.name + "/"]

    def walk(current: Path, prefix: str = "", depth: int = 0):
        if depth >= max_depth:
            return

        try:
            children = sorted(
                [p for p in current.iterdir() if not should_exclude(p, root)],
                key=lambda p: (p.is_file(), p.name.lower())
            )
        except PermissionError:
            return

        for i, child in enumerate(children):
            connector = "└── " if i == len(children) - 1 else "├── "
            lines.append(prefix + connector + child.name + ("/" if child.is_dir() else ""))
            if child.is_dir():
                extension = "    " if i == len(children) - 1 else "│   "
                walk(child, prefix + extension, depth + 1)

    walk(root)
    return "\n".join(lines)


def collect_files(root: Path, max_file_kb: int) -> tuple[list[Path], list[Path]]:
    priority_files: list[Path] = []
    other_text_files: list[Path] = []

    for path in root.rglob("*"):
        if not path.is_file():
            continue
        if should_exclude(path, root):
            continue
        if path.stat().st_size > max_file_kb * 1024:
            continue
        if not is_probably_text_file(path):
            continue

        rel = path.relative_to(root).as_posix()
        is_priority = (
            path.name in PRIORITY_FILENAMES
            or matches_any_pattern(rel, PRIORITY_PATH_PATTERNS)
        )

        if is_priority:
            priority_files.append(path)
        else:
            other_text_files.append(path)

    priority_files = sorted(set(priority_files), key=lambda p: p.relative_to(root).as_posix())
    other_text_files = sorted(set(other_text_files), key=lambda p: p.relative_to(root).as_posix())
    return priority_files, other_text_files


def file_header(path: Path, root: Path) -> str:
    rel = path.relative_to(root).as_posix()
    size_kb = path.stat().st_size / 1024
    return (
        "\n" + "=" * 100 + "\n"
        f"FILE: {rel}\n"
        f"SIZE_KB: {size_kb:.1f}\n"
        "=" * 100 + "\n"
    )


def build_prompting_footer() -> str:
    return """
====================================================================================================
SECCIÓN FINAL: CÓMO USAR ESTE ARCHIVO CON UNA IA
====================================================================================================

Ejemplos de mensajes que puedes pegar junto con este archivo:

1) Para migración Android -> iOS:
"Analiza este contexto completo del proyecto y dame un prompt técnico para Codex que continúe la migración a iOS sin romper la lógica existente de Android. Quiero que respete arquitectura, Firebase, navegación, modelos y estilo visual."

2) Para corregir errores:
"Basándote en este contexto, dame un prompt para Codex que localice y corrija los errores de compilación y de integración en iOS. Quiero cambios mínimos y seguros."

3) Para replicar una pantalla:
"Con este contexto, dame un prompt para Codex para recrear en iOS la pantalla X que ya existe en Android, manteniendo estructura, campos, validaciones y comportamiento."

4) Para revisar arquitectura:
"Lee este contexto y dame un diagnóstico técnico del proyecto: qué está bien, qué falta para iOS y en qué orden conviene hacerlo."

5) Para generar tareas:
"A partir de este contexto, dame una checklist priorizada de migración a iOS por fases."

Consejo:
- Si el archivo es demasiado grande, puedes generarlo otra vez bajando el límite:
  python export_project_context.py . --max-file-kb 120 --max-total-mb 10
"""


def generate_context(root: Path, output_file: Path, max_file_kb: int, max_total_mb: int, tree_depth: int) -> None:
    priority_files, other_text_files = collect_files(root, max_file_kb=max_file_kb)
    max_total_bytes = max_total_mb * 1024 * 1024
    written_bytes = 0

    with output_file.open("w", encoding="utf-8") as f:
        def write(text: str):
            nonlocal written_bytes
            data = text.encode("utf-8", errors="ignore")
            if written_bytes + len(data) > max_total_bytes:
                remaining = max_total_bytes - written_bytes
                if remaining > 0:
                    f.write(data[:remaining].decode("utf-8", errors="ignore"))
                    written_bytes += remaining
                raise StopIteration
            f.write(text)
            written_bytes += len(data)

        write("CONTEXTO DE PROYECTO PARA IA / CODEX\n")
        write("=" * 100 + "\n")
        write(f"ROOT_PATH: {root.resolve()}\n")
        write(f"MAX_FILE_KB: {max_file_kb}\n")
        write(f"MAX_TOTAL_MB: {max_total_mb}\n")
        write(f"TOTAL_PRIORITY_FILES: {len(priority_files)}\n")
        write(f"TOTAL_OTHER_TEXT_FILES: {len(other_text_files)}\n\n")

        write("INSTRUCCIÓN PARA LA IA:\n")
        write(
            "Lee este archivo completo como contexto del proyecto. "
            "Asume que quiero ayuda técnica precisa, con cambios mínimos, seguros y coherentes con la arquitectura existente. "
            "Prioriza mantener compatibilidad con Firebase, iOS, Android, modelos de datos, navegación y estructura real del repositorio.\n\n"
        )

        write("ÁRBOL DEL PROYECTO\n")
        write("-" * 100 + "\n")
        write(build_tree(root, max_depth=tree_depth))
        write("\n\n")

        write("ARCHIVOS PRIORITARIOS\n")
        write("-" * 100 + "\n")

        try:
            for path in priority_files:
                text = safe_read_text(path)
                if text is None:
                    continue
                text = mask_secrets(text)
                write(file_header(path, root))
                write(text)
                if not text.endswith("\n"):
                    write("\n")

            write("\nARCHIVOS ADICIONALES DE TEXTO\n")
            write("-" * 100 + "\n")

            for path in other_text_files:
                if path in priority_files:
                    continue
                text = safe_read_text(path)
                if text is None:
                    continue
                text = mask_secrets(text)
                write(file_header(path, root))
                write(text)
                if not text.endswith("\n"):
                    write("\n")

            write(build_prompting_footer())

        except StopIteration:
            f.write(
                "\n\n[AVISO] Se alcanzó el límite máximo del archivo final. "
                "Vuelve a ejecutar el script con un límite mayor o con un proyecto más filtrado.\n"
            )


def main():
    parser = argparse.ArgumentParser(description="Exporta el contexto de un proyecto a un archivo de texto optimizado para IA.")
    parser.add_argument("project_root", help="Ruta a la raíz del proyecto")
    parser.add_argument("-o", "--output", default="project_context_for_ai.txt", help="Archivo de salida")
    parser.add_argument("--max-file-kb", type=int, default=250, help="Tamaño máximo por archivo individual en KB")
    parser.add_argument("--max-total-mb", type=int, default=15, help="Tamaño máximo total del archivo generado en MB")
    parser.add_argument("--tree-depth", type=int, default=5, help="Profundidad máxima del árbol del proyecto")
    args = parser.parse_args()

    root = Path(args.project_root).resolve()
    if not root.exists() or not root.is_dir():
        print(f"[ERROR] La ruta no existe o no es una carpeta: {root}")
        sys.exit(1)

    output_file = Path(args.output).resolve()
    generate_context(
        root=root,
        output_file=output_file,
        max_file_kb=args.max_file_kb,
        max_total_mb=args.max_total_mb,
        tree_depth=args.tree_depth
    )

    print(f"[OK] Archivo generado: {output_file}")


if __name__ == "__main__":
    main()
