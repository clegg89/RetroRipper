set(STM32_WL_SUBFAMILIES
	# All H7's have an M4
	M4
	# Dual-core variants also have an M0PLUS
	M0PLUS
)

set(STM32_WL_M4_COMPILE_OPTIONS
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m4>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=soft>
)
set(STM32_WL_M4_LINK_OPTIONS
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m4>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=soft>
)

set(STM32_WL_M0PLUS_COMPILE_OPTIONS
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m0plus>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=soft>
)
set(STM32_WL_M0PLUS_LINK_OPTIONS
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m0plus>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=soft>
)
