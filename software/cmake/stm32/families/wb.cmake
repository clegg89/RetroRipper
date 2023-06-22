set(STM32_WB_TYPES 
	# Standard Lines
	WB15xx WB35xx WB55xx
	# Value Lines
	WB10xx WB30xx WB50xx
	# Module Lines
	WB1Mxx WB5Mxx
)

_stm32_create_family_targets(
	FAMILY WB
	SUBFAMILY M4
	TYPES ${STM32_WB_TYPES}
)

target_compile_options(STM32::WB::M4 INTERFACE
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m4>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv5-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
target_link_options(STM32::WB::M4 INTERFACE
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m4>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv5-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)