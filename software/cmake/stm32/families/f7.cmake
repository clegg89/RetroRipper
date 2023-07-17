set(STM32_F7_SUBFAMILIES
	# Single-Precision FPU
	SP
	# Double-Precision FPU
	DP
)

set(STM32_F7_SP_COMPILE_OPTIONS 
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m7>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv5-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
set(STM32_F7_SP_LINK_OPTIONS 
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m7>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv5-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)

set(STM32_F7_DP_COMPILE_OPTIONS 
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m7>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv5-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
set(STM32_F7_DP_LINK_OPTIONS 
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m7>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv5-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
