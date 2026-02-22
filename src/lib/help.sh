#!/usr/bin/env bash
# src/lib/help.sh
#
# Help output template.
# Sections: header / DESCRIPTION / USAGE / AVAILABLE SUBCOMMANDS / FLAGS / EXAMPLES / LEARN MORE
# All output is in English only (per spec SPEC-COMMON).

# print_help() — print command help to stdout
#
# Output sections:
#   header                 - one-line summary (<name> - <description>)
#   DESCRIPTION:           - overview of corun
#   USAGE:                 - how to use the command
#   AVAILABLE SUBCOMMANDS: - list of available subcommands
#   FLAGS:                 - available flags
#   EXAMPLES:              - usage examples
#   LEARN MORE:            - links for further information
#
# Args:
#   subcommand (optional) - when provided, print subcommand-specific help
#
# Usage:
#   print_help
#   print_help run
print_help() {
  local subcommand="${1:-}"

  if [[ -n "$subcommand" ]]; then
    _print_subcommand_help "$subcommand"
    return 0
  fi

  _print_root_help
}

# _print_root_help() — print root command help (internal)
_print_root_help() {
  printf '%s\n' \
    "corun - GitHub Copilot CLI batch runner." \
    "" \
    "DESCRIPTION:" \
    "  Runs multiple GitHub Copilot CLI prompts sequentially in non-interactive mode." \
    "" \
    "USAGE:" \
    "  corun <subcommand> [flags] [arguments]" \
    "" \
    "AVAILABLE SUBCOMMANDS:" \
    "  run               Handles execution of multiple prompts." \
    "  gen               Generate a template for a prompt definition." \
    "" \
    "FLAGS:" \
    "  --help            Show help for command" \
    "  --version         Show version" \
    "  --verbose         Enable verbose logging" \
    "" \
    "EXAMPLES:" \
    "  corun --version" \
    "  corun --help" \
    '  corun run "prompt1" "prompt2"' \
    '  corun run --prompt prompts.yaml' \
    "  corun gen --output prompts.yaml \"prompt1\" \"prompt2\"" \
    "" \
    "LEARN MORE:" \
    "  Use \`corun <subcommand> --help\` for more information about a command."
}

# _print_subcommand_help() — print subcommand-specific help (internal)
_print_subcommand_help() {
  local subcommand="$1"
  case "$subcommand" in
    run)
      printf '%s\n' \
        "corun run - Handles execution of multiple prompts." \
        "" \
        "DESCRIPTION:" \
        "  Read prompts from arguments or a prompt file (YAML) and execute each" \
        "  sequentially via GitHub Copilot CLI in non-interactive mode." \
        "" \
        "USAGE:" \
        "  corun run [flags] [arguments]" \
        "" \
        "AVAILABLE SUBCOMMANDS:" \
        "  (no subcommands)" \
        "" \
        "FLAGS:" \
        "  --help            Show help for command" \
        "  --prompt          Path to a prompt definition file (YAML)" \
        "  --verbose         Enable verbose logging" \
        "" \
        "EXAMPLES:" \
        '  corun run "prompt1" "prompt2"' \
        "  corun run --prompt prompts.yaml" \
        "" \
        "LEARN MORE:" \
        "  Use \`corun --help\` for more information about a command."
      ;;
    gen)
      printf '%s\n' \
        "corun gen - Generate a template for a prompt definition." \
        "" \
        "DESCRIPTION:" \
        "  Generate a YAML prompt definition template file from the given prompt strings." \
        "" \
        "USAGE:" \
        "  corun gen [flags] [arguments]" \
        "" \
        "AVAILABLE SUBCOMMANDS:" \
        "  (no subcommands)" \
        "" \
        "FLAGS:" \
        "  --help            Show help for command" \
        "  --output          Output file path (default: prompts.yaml)" \
        "  --verbose         Enable verbose logging" \
        "" \
        "EXAMPLES:" \
        "  corun gen" \
        '  corun gen --output prompts.yaml "prompt1" "prompt2"' \
        "" \
        "LEARN MORE:" \
        "  Use \`corun --help\` for more information about a command."
      ;;
    *)
      printf '%s\n' \
        "corun: '$subcommand': unknown subcommand" \
        "" \
        "USAGE:" \
        "  corun <subcommand> [flags] [arguments]" \
        "" \
        "EXAMPLES:" \
        "  corun --help" \
        "" \
        "LEARN MORE:" \
        "  Use \`corun --help\` to see available commands."
      ;;
  esac
}
