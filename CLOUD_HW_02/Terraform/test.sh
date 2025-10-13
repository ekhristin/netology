#!/bin/bash

# Список IP адресов инстансов
INSTANCES=("46.21.246.17" "51.250.80.5" "89.169.159.96")
# IP адрес балансировщика
BALANCER_IP="130.193.35.20"

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== ПРОВЕРКА ИНСТАНСОВ INSTANCE GROUP ===${NC}"
echo "Количество инстансов: ${#INSTANCES[@]}"
echo "Балансировщик: $BALANCER_IP"
echo ""

# Функция проверки одного инстанса
check_instance() {
    local ip=$1
    local instance_num=$2
    
    echo -e "${YELLOW}🔍 Проверка инстанса ${instance_num}: ${ip}${NC}"
    
    # Проверка доступности по HTTP
    echo -n "   HTTP доступность: "
    if curl -s -f --max-time 5 "http://${ip}/" > /dev/null; then
        echo -e "${GREEN}✓ ДОСТУПЕН${NC}"
    else
        echo -e "${RED}✗ НЕДОСТУПЕН${NC}"
        return 1
    fi
    
    # Получаем содержимое страницы
    CONTENT=$(curl -s --max-time 5 "http://${ip}/")
    
    # Проверка содержимого страницы
    echo -n "   Содержимое страницы: "
    if echo "$CONTENT" | grep -q "Hello from LAMP"; then
        echo -e "${GREEN}✓ LAMP страница загружена${NC}"
    else
        echo -e "${YELLOW}⚠ Нестандартное содержимое${NC}"
    fi
    
    # Проверка картинки на странице
    echo -n "   Наличие картинки: "
    IMAGE_URL=$(echo "$CONTENT" | grep -oP "src='[^']*'" | sed "s/src='//g" | sed "s/'//g")
    if [ -n "$IMAGE_URL" ]; then
        echo -e "${GREEN}✓ Картинка найдена${NC}"
        echo -e "   URL картинки: ${CYAN}${IMAGE_URL}${NC}"
        
        # Проверка доступности картинки
        echo -n "   Доступность картинки: "
        if curl -s -f --max-time 5 -I "$IMAGE_URL" | grep -q "200"; then
            echo -e "${GREEN}✓ ДОСТУПНА${NC}"
        else
            echo -e "${RED}✗ НЕДОСТУПНА${NC}"
        fi
    else
        echo -e "${RED}✗ Картинка не найдена${NC}"
    fi
    
    # Проверка времени ответа
    echo -n "   Время ответа: "
    RESPONSE_TIME=$(curl -s -w "%{time_total}s" -o /dev/null --max-time 5 "http://${ip}/")
    echo -e "${BLUE}${RESPONSE_TIME}${NC}"
    
    echo ""
}

# Функция проверки балансировщика
check_balancer() {
    echo -e "${BLUE}=== ПРОВЕРКА БАЛАНСИРОВЩИКА ===${NC}"
    echo -e "${YELLOW}Балансировщик: ${BALANCER_IP}${NC}"
    
    # Проверка доступности балансировщика
    echo -n "HTTP доступность: "
    if curl -s -f --max-time 5 "http://${BALANCER_IP}/" > /dev/null; then
        echo -e "${GREEN}✓ ДОСТУПЕН${NC}"
    else
        echo -e "${RED}✗ НЕДОСТУПЕН${NC}"
        return 1
    fi
    
    # Тестирование распределения запросов
    echo ""
    echo -e "${YELLOW}Тестирование распределения запросов (15 запросов):${NC}"
    
    declare -A ip_distribution
    
    for i in {1..15}; do
        # Получаем ответ от балансировщика
        RESPONSE=$(curl -s --max-time 3 "http://${BALANCER_IP}/")
        
        # Определяем с какого инстанса пришел ответ по IP в заголовках
        # или по уникальному контенту (если есть различия)
        BACKEND_IP="unknown"
        
        # Проверяем наличие стандартного контента
        if echo "$RESPONSE" | grep -q "Hello from LAMP"; then
            BACKEND_IP="lamp_instance"
        fi
        
        ((ip_distribution["$BACKEND_IP"]++))
        echo -e "Запрос ${i}: ${GREEN}${BACKEND_IP}${NC}"
        
        sleep 0.5
    done
    
    echo ""
    echo -e "${BLUE}=== СТАТИСТИКА РАСПРЕДЕЛЕНИЯ ===${NC}"
    for ip in "${!ip_distribution[@]}"; do
        count=${ip_distribution[$ip]}
        percentage=$((count * 100 / 15))
        echo -e "  ${ip}: ${count} запросов (${percentage}%)"
    done
    
    # Проверка картинки через балансировщик
    echo ""
    echo -e "${YELLOW}Проверка картинки через балансировщик:${NC}"
    BALANCER_CONTENT=$(curl -s --max-time 5 "http://${BALANCER_IP}/")
    BALANCER_IMAGE_URL=$(echo "$BALANCER_CONTENT" | grep -oP "src='[^']*'" | sed "s/src='//g" | sed "s/'//g")
    
    if [ -n "$BALANCER_IMAGE_URL" ]; then
        echo -e "   URL картинки: ${CYAN}${BALANCER_IMAGE_URL}${NC}"
        echo -n "   Доступность: "
        if curl -s -f --max-time 5 -I "$BALANCER_IMAGE_URL" | grep -q "200"; then
            echo -e "${GREEN}✓ ДОСТУПНА${NC}"
        else
            echo -e "${RED}✗ НЕДОСТУПНА${NC}"
        fi
    fi
    
    echo ""
}

# Функция сравнения ответов
compare_responses() {
    echo -e "${BLUE}=== СРАВНЕНИЕ ОТВЕТОВ ИНСТАНСОВ ===${NC}"
    
    declare -A responses
    
    for ip in "${INSTANCES[@]}"; do
        echo -n "Получаем ответ от ${ip}: "
        RESPONSE=$(curl -s --max-time 3 "http://${ip}/" | head -c 100)
        if [ -n "$RESPONSE" ]; then
            responses["$ip"]="$RESPONSE"
            echo -e "${GREEN}✓${NC}"
        else
            echo -e "${RED}✗${NC}"
        fi
    done
    
    # Проверяем идентичность ответов
    echo ""
    echo -n "Идентичность ответов: "
    UNIQUE_RESPONSES=$(printf "%s\n" "${responses[@]}" | sort -u | wc -l)
    if [ "$UNIQUE_RESPONSES" -eq 1 ]; then
        echo -e "${GREEN}✓ Все инстансы возвращают одинаковый ответ${NC}"
    else
        echo -e "${YELLOW}⚠ Ответы различаются между инстансами${NC}"
    fi
}

# Главная функция
main() {
    # Проверяем доступность утилит
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}Ошибка: curl не установлен${NC}"
        exit 1
    fi
    
    # Проверяем каждый инстанс
    INSTANCE_NUM=1
    for ip in "${INSTANCES[@]}"; do
        check_instance "$ip" "$INSTANCE_NUM"
        ((INSTANCE_NUM++))
    done
    
    # Проверяем балансировщик
    check_balancer
    
    # Сравниваем ответы
    compare_responses
    
    # Итоговая статистика
    echo -e "${BLUE}=== ИТОГОВАЯ СТАТИСТИКА ===${NC}"
    echo "Всего инстансов: ${#INSTANCES[@]}"
    echo "Балансировщик: $BALANCER_IP"
    echo "Проверка завершена: $(date)"
    
    # Полезные команды для ручной проверки
    echo ""
    echo -e "${CYAN}=== ДЛЯ РУЧНОЙ ПРОВЕРКИ ===${NC}"
    echo "curl http://$BALANCER_IP/"
    echo "curl http://${INSTANCES[0]}/"
    echo "curl -I 'https://khristin-111025.storage.yandexcloud.net/image.jpg'"
}

# Запуск главной функции
main