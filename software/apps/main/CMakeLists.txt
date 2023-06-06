cmake_minimum_required(VERSION 3.15.3)

project(RetroRipper)

enable_language(CXX C ASM)
#set(CMAKE_C_STANDARD 99)
#set(CMAKE_C_STANDARD_REQUIRED ON)
#set(CMAKE_C_EXTENSIONS OFF)

include(hal)
include(ripper)
include(apps)

set(STM32CUBEMX_GENERATED_FILES
	# HAL
	Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_gpio_ex.c
	Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_tim.c
	Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_tim_ex.c
	Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_uart.c
	Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal.c
	Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_rcc.c
	Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_rcc_ex.c
	Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_gpio.c
	Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_dma.c
	Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_cortex.c
	Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_pwr.c
	Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_flash.c
	Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_flash_ex.c
	Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_exti.c

	# Core
	Src/main.c
	Src/stm32f1xx_it.c
	Src/stm32f1xx_hal_msp.c
	Src/system_stm32f1xx.c  

	# Startup
	startup_stm32f103xb.s
)

set(EXECUTABLE ${PROJECT_NAME}.out)

add_executable(${EXECUTABLE} ${STM32CUBEMX_GENERATED_FILES})

target_compile_definitions(${EXECUTABLE} PRIVATE
	-DUSE_HAL_DRIVER
	-DSTM32F103xB)

target_include_directories(${EXECUTABLE} PRIVATE
	Inc
	Drivers/STM32F1xx_HAL_Driver/Inc
	Drivers/STM32F1xx_HAL_Driver/Inc/Legacy
	Drivers/CMSIS/Device/ST/STM32F1xx/Include
	Drivers/CMSIS/Include)

target_compile_options(${EXECUTABLE} PRIVATE
	-mcpu=cortex-m3
	-mthumb
	-Wall
	-fdata-sections
	-ffunction-sections
	# Look up cmake generator expressions
	# Basically says "If we're in debug config, use -Og flag"
	$<$<CONFIG:Debug>:-Og>)

target_link_options(${EXECUTABLE} PRIVATE
	-T${CMAKE_SOURCE_DIR}/STM32F103RBTx_FLASH.ld
	-mcpu=cortex-m3
	-mthumb
	-specs=nano.specs
	-lc
	-lm
	# https://community.st.com/s/question/0D53W00001vno1oSAA/warning-elffile-has-a-load-segment-with-rwx-permissions
	-Wl,--no-warn-rwx-segment
	-Wl,-Map=${PROJECT_NAME}.map,--cref
	-Wl,--gc-sections)

# Print executable size
add_custom_command(TARGET ${EXECUTABLE}
	POST_BUILD
	# TODO toolchain independent
	COMMAND arm-none-eabi-size ${EXECUTABLE})

# Create hex file
add_custom_command(TARGET ${EXECUTABLE}
	POST_BUILD
	COMMAND arm-none-eabi-objcopy -O ihex ${EXECUTABLE} ${PROJECT_NAME}.hex
	COMMAND arm-none-eabi-objcopy -O binary ${EXECUTABLE} ${PROJECT_NAME}.bin)
