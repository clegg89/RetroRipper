set(STM32_U5_COMPILE_OPTIONS
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m33>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv5-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)

set(STM32_U5_LINK_OPTIONS
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m33>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv5-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
