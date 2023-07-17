set(STM32_H7_SUBFAMILIES
	# All H7's have an M7
	M7
	# Dual-core variants also have an M4
	M4
)

set(STM32_H7_M7_COMPILE_OPTIONS
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m7>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv5-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
set(STM32_H7_M7_LINK_OPTIONS
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m7>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv5-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)

set(STM32_H7_M4_COMPILE_OPTIONS
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m4>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv4-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
set(STM32_H7_M4_LINK_OPTIONS
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m4>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv4-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
