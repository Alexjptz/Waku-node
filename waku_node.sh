#!/bin/bash

tput reset
tput civis

show_orange() {
    echo -e "\e[33m$1\e[0m"
}

show_blue() {
    echo -e "\e[34m$1\e[0m"
}

show_green() {
    echo -e "\e[32m$1\e[0m"
    echo
}

show_red() {
    echo -e "\e[31m$1\e[0m"
}

exit_script() {
    show_red "Скрипт остановлен (Script stopped)"
        echo
        exit 0
}

incorrect_option () {
    echo
    show_red "Неверная опция. Пожалуйста, выберите из тех, что есть."
    echo
    show_red "Invalid option. Please choose from the available options."
    echo
}

process_notification() {
    local message="$1"
    show_orange "$message"
    sleep 1 && echo
}

install_or_update_docker() {
    process_notification "Ищем Docker (Looking for Docker)..."
    if which docker > /dev/null 2>&1; then
        show_green "Docker уже установлен (Docker is already installed)"
        echo
        # Try to update Docker
        process_notification "Обновляем Docker до последней версии (Updating Docker to the latest version)..."

        if sudo apt install apt-transport-https ca-certificates curl software-properties-common -y &&
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
            sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" &&
            sudo apt-get update &&
            sudo apt-get install --only-upgrade docker-ce docker-ce-cli containerd.io docker-compose-plugin -y; then
            sleep 1
            echo -e "Обновление Docker (Docker update): \e[32mУспешно (Success)\e[0m"
            echo
        else
            echo -e "Обновление Docker (Docker update): \e[31мОшибка (Error)\e[0m"
            echo
        fi
    else
        # Install docker
        show_red "Docker не установлен (Docker not installed)"
        echo
        process_notification "\e[33mУстанавливаем Docker (Installing Docker)...\e[0m"

        if sudo apt install apt-transport-https ca-certificates curl software-properties-common -y &&
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" &&
        sudo apt-get update &&
        sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y; then
            sleep 1
            echo -e "Установка Docker (Docker installation): \e[32mУспешно (Success)\e[0m"
            echo
        else
            echo -e "Установка Docker (Docker installation): \e[31mОшибка (Error)\e[0m"
            echo
        fi
    fi
}

run_commands() {
    local commands="$*"

    if eval "$commands"; then
        sleep 1
        echo
        show_green "Успешно (Success)"
        echo
    else
        sleep 1
        echo
        show_red "Ошибка (Fail)"
        echo
    fi
}

print_logo () {
    echo
    show_orange " ____    __    ____      ___       __  ___  __    __ " && sleep 0.2
    show_orange " \   \  /  \  /   /     /   \     |  |/  / |  |  |  | " && sleep 0.2
    show_orange "  \   \/    \/   /     /  ^  \    |  '  /  |  |  |  | " && sleep 0.2
    show_orange "   \            /     /  /_\  \   |    <   |  |  |  | " && sleep 0.2
    show_orange "    \    /\    /     /  _____  \  |  .  \  |   --'  | " && sleep 0.2
    show_orange "     \__/  \__/     /__/     \__\ |__|\__\  \______/ " && sleep 0.2
    echo
    sleep 1
}

stop_node () {
    if screen -r pipe -X quit; then
        sleep 1
        show_green "Успешно (Success)"
        echo
    else
        sleep 1
        show_blue "Сессия не найдена (Session doesn't exist)"
        echo
    fi
}

while true; do
    print_logo
    show_green "------ MAIN MENU ------ "
    echo "1. Подготовка (Preparation)"
    echo "2. Установка (Installation)"
    echo "3. Настройка (Tunning)"
    echo "4. Управление (Operational menu)"
    echo "5. Монитор (Monitor)"
    echo "6. Логи (Logs)"
    echo "7. Удаление (Delete)"
    echo "8. Выход (Exit)"
    echo
    read -p "Выберите опцию (Select option): " option

    case $option in
        1)
            # PREPARATION
            process_notification "Начинаем подготовку (Starting preparation)..."
            run_commands "cd $HOME && sudo apt update && sudo apt upgrade -y"
            run_commands "apt install unzip screen nano mc curl git jq lz4"

            install_or_update_docker

            apt remove docker-compose
            apt install docker-compose

            show_green "--- ПОГОТОВКА ЗАЕРШЕНА. PREPARATION COMPLETED ---"
            ;;
        2)
            # INSTALLATION
            process_notification "Установка (Installation)..."
            run_commands "cd $HOME && git clone https://github.com/waku-org/nwaku-compose && cd nwaku-compose"

            process_notification "Создаем env (Create env)..."
            run_commands "cp .env.example .env"
            echo
            show_green "--- УСТАНОВКА ЗАВЕРШЕНА. INSTALLATION COMPLETED ---"
            ;;
        3)
            # TUNNING
            process_notification "Настройка (Tunning)..."
            cd $HOME/nwaku-compose

            read -p "Введите (Enter) INFURA API URL: " INFURA_API
            read -p "Введите (Enter) WALLET PRIVATE KEY: " PRIVATE_KEY
            read -p "Придумайте пароль (come up with a password): " PASSWORD
            echo

            if sed -i "s|^RLN_RELAY_ETH_CLIENT_ADDRESS=.*|RLN_RELAY_ETH_CLIENT_ADDRESS=$INFURA_API|" .env && \
                sed -i "s|^ETH_TESTNET_KEY=.*|ETH_TESTNET_KEY=$PRIVATE_KEY|" .env && \
                sed -i "s|^RLN_RELAY_CRED_PASSWORD=.*|RLN_RELAY_CRED_PASSWORD=$PASSWORD|" .env
            then
                sleep 1
                show_green ".env обновлен (Updated)"
            else
                sleep 1
                echo
                show_blue ".env не существует (doesn't exist)"
                echo
            fi
            show_green "--- НАСТРОЙКА ЗАВЕРШЕНА. TUNNING COMPLETED ---"
            ;;
        4)
            # OPERATIONAL
            echo
            while true; do
                show_green "------ OPERATIONAL MENU ------ "
                echo "1. Регистрация (Registration)"
                echo "2. Зaпустить (Start)"
                echo "3. Остановить (Stop)"
                echo "4. Обновить (Update)"
                echo "5. Выход (Exit)"
                echo
                read -p "Выберите опцию (Select option): " option
                echo
                case $option in
                    1)
                        # REGISTRATION
                        process_notification "Регистрация (Registration)..."
                        cd $HOME/nwaku-compose && ./register_rln.sh
                        ;;
                    2)
                        # START
                        process_notification "Запускаем (Start)..."
                        cd $HOME/nwaku-compose && docker-compose up -d
                        ;;
                    3)
                        # STOP
                        process_notification "Останавливаем (Stop)..."
                        cd $HOME/nwaku-compose && docker-compose down
                        ;;
                    4)
                        # UPDATE
                        process_notification "Обновляем (Updating)..."
                        cd $HOME/nwaku-compose
                        git stash && git pull && git stash pop
                        docker compose down
                        docker compose up -d
                        ;;
                    5)
                        break
                        ;;
                    *)
                        incorrect_option
                        ;;
                esac
            done
            ;;
        5)
            # MONITOR
            SERVER_IP=$(hostname -I | awk '{print $1}')
            show_green "click ----> http://$SERVER_IP:3000/d/yns_4vFVk/nwaku-monitoring"
            ;;
        6)
            # LOGS
            docker-compose logs -f nwaku
            ;;
        7)
            # DELETE
            process_notification "Удаление (Deleting)..."
            echo
            while true; do
                read -p "Удалить ноду? Delete node? (yes/no): " option

                case "$option" in
                    yes|y|Y|Yes|YES)
                        process_notification "Останавливаем (Stopping)..."
                        run_commands "cd $HOME/nwaku-compose && docker-compose down"

                        process_notification "Чистим (Cleaning)..."
                        run_commands "rm -rvf $HOME/nwaku-compose"

                        show_green "--- НОДА УДАЛЕНА. NODE DELETED. ---"
                        break
                        ;;
                    no|n|N|No|NO)
                        process_notification "Отмена (Cancel)"
                        echo
                        break
                        ;;
                    *)
                        incorrect_option
                        ;;
                esac
            done
            ;;
        8)
            # EXIT
            exit_script
            ;;
        *)
            incorrect_option
            ;;
    esac
done
