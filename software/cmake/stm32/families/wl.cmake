set(STM32_WL_TYPES 
	# Single-Core Lines
	WLE4xx WLE5xx
	# Dual-Core Lines
	WL54xx WL55xx
	# Implemented in CMSIS device header, but no product page
	WL5Mxx
)

set(STM32_WL_DUAL_CORE_TYPES
	# Dual-Core Lines
	WL54xx WL55xx
)

# All variants have a M4
_stm32_create_family_targets(
	FAMILY WL
	SUBFAMILY M4
	TYPES ${STM32_WL_TYPES}
)

target_compile_options(STM32::WL::M4 INTERFACE 
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m4>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=soft>
)
target_link_options(STM32::WL::M4 INTERFACE 
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m4>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=soft>
)

# Mult-core variants also have an M0+
_stm32_create_family_targets(
	FAMILY WL
	SUBFAMILY M0PLUS
	TYPES ${STM32_WL_DUAL_CORE_TYPES}
)

target_compile_options(STM32::WL::M0PLUS INTERFACE 
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m0plus>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=soft>
)
target_link_options(STM32::WL::M0PLUS INTERFACE 
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m0plus>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=soft>
)
