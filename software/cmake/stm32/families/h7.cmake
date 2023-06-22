# Note: The xxQ types below are not listed in the getting
# started page, but are in the CMSIS device header files
set(STM32_H7_TYPES
# Value Lines
## STM32H730
H730xx H730xxQ
## STM32H750
H750xx
## STM32H7B0
H7B0xx H7B0xxQ
# Single-Core Lines
## STM32H723/STM32H733
H723xx H733xx
## STM32H725/STM32H735
H725xx H735xx
## STM32H742
H742xx
## STM32H743/STM32H753
H743xx H753xx
## STM32H7A3/STM32H7B3
H7A3xx H7A3xxQ H7B3xx H7B3xxQ
# Dual-Core Lines
## STM32H745/STM32H755
H745xx H755xx
## STM32H747/STM32H757
H747xx H757xx
)

set(STM32_H7_DUAL_CORE_TYPES
# Dual-core lines
# STM32H745/STM32H755
H745xx H755xx
# STM32H747/STM32H757
H747xx H757xx
)

_stm32_create_family_targets(
	FAMILY H7
	SUBFAMILY M7
	TYPES ${STM32_H7_TYPES} # All H7's have an M7
)

target_compile_options(STM32::H7::M7 INTERFACE 
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m7>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv5-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
target_link_options(STM32::H7::M7 INTERFACE 
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m7>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv5-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
# Technically not required for single-core lines, but no harm
target_compile_definitions(STM32::H7::M7 INTERFACE 
	CORE_CM7
)

_stm32_create_family_targets(
	FAMILY H7
	SUBFAMILY M4
	TYPES ${STM32_H7_DUAL_CORE_TYPES} # Only multi-core variants
)

target_compile_options(STM32::H7::M4 INTERFACE 
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m4>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv4-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
target_link_options(STM32::H7::M4 INTERFACE 
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m4>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv4-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
target_compile_definitions(STM32::H7::M4 INTERFACE 
	CORE_CM4
)
