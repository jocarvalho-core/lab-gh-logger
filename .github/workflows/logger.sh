#!/bin/bash
# .github/scripts/logger.sh

COMMAND_FILE=$1
STEP_NAME="${GITHUB_STEP_NAME:-"Step sem Nome"}"
JOB_NAME="${GITHUB_JOB:-"Job Desconhecido"}"
JSON_LOG="/tmp/ai_failure_context.json"

START_TIME=$(date +%s)

echo "::group::🚀 INÍCIO: $STEP_NAME"

# Executa e captura o log
bash "$COMMAND_FILE" 2>&1 | tee /tmp/step_output.log
EXIT_CODE=${PIPESTATUS[0]}

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "::endgroup::"

if [ $EXIT_CODE -ne 0 ]; then
    echo "🔚 FIM: $STEP_NAME (FALHOU em ${DURATION}s)"

    # Captura os dados brutos (o jq cuidará do escape das aspas e quebras de linha)
    LOG_RAW=$(tail -n 50 /tmp/step_output.log | tr -d '\r')
    CMD_RAW=$(cat "$COMMAND_FILE" | tr -d '\r')

    # Monta o JSON de forma segura usando o próprio jq
    # --arg cria variáveis internas no jq que são automaticamente "escapadas"
    jq -n \
      --arg job "$JOB_NAME" \
      --arg step "$STEP_NAME" \
      --arg dur "${DURATION}s" \
      --arg exit "$EXIT_CODE" \
      --arg cmd "$CMD_RAW" \
      --arg log "$LOG_RAW" \
      '{job: $job, step: $step, duration: $dur, exit_code: $exit, command: $cmd, log: $log}' >> "$JSON_LOG"
else
    echo "🔚 FIM: $STEP_NAME (SUCESSO em ${DURATION}s)"
fi

exit $EXIT_CODE