set(STM32_WB_SUBFAMILIES
	# The only subfamily we support is the M4
	M4
)

set(STM32_WB_M4_COMPILE_OPTIONS
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m4>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv5-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)

set(STM32_WB_M4_LINK_OPTIONS
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m4>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv5-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
