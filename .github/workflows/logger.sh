#!/bin/bash
# .github/scripts/logger.sh

COMMAND_FILE=$1

STEP_NAME="${GITHUB_STEP_NAME:-"Step sem Nome"}"
JSON_LOG="/tmp/ai_failure_context.json"

START_TIME=$(date +%s)

echo "::group::🚀 INÍCIO: $STEP_NAME"

# Executa o comando e captura todo o output para um arquivo temporário de log
# Usamos o 'tee' para que o utilizador ainda veja o log em tempo real no GitHub
bash "$COMMAND_FILE" 2>&1 | tee /tmp/step_output.log
EXIT_CODE=${PIPESTATUS[0]}

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "::endgroup::"

if [ $EXIT_CODE -ne 0 ]; then
    echo "🔚 FIM: $STEP_NAME (FALHOU em ${DURATION}s)"
    
    LOG_TAIL=$(tail -n 50 /tmp/step_output.log | tr -d '\r' | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')

    CMD_CLEAN=$(cat "$COMMAND_FILE" | tr -d '\r' | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')

    echo "{\"step\": \"$STEP_NAME\", \"duration\": \"${DURATION}s\", \"exit_code\": $EXIT_CODE, \"command\": \"$CMD_CLEAN\", \"log\": \"$LOG_TAIL\"}" >> "$JSON_LOG"

    echo "------------JSON PARA IA--------------------"
    cat $JSON_LOG
    echo "------------JSON PARA IA--------------------"

else
    echo "DEU BÃO"
    echo "🔚 FIM: $STEP_NAME (SUCESSO em ${DURATION}s)"
fi

exit $EXIT_CODE
