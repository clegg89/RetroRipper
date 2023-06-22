set(STM32_F7_SP_TYPES
	# Value Lines
	## STM32F7x0
	F730xx F750xx
	# Foundation Lines
	## STM32F7x2
	F722xx F732xx
	## STM32F7x3
	F723xx F733xx
	# Advanced Lines (SP)
	## STM32F7x5 (SP)
	F745xx F746xx
	## STM32F7x6
	F756xx
)

set(STM32_F7_DP_TYPES
	# Advanced Lines (DP)
	## STM32F7x5 (DP)
	F765xx
	## STM32F7x7
	F767xx F777xx
	## STM32F7x9
	F769xx F779xx
)

stm32_create_family_targets(
	FAMILY F7
	SUBFAMILY SP
	TYPES ${STM32_F7_SP_TYPES}
)

stm32_create_family_targets(
	FAMILY F7
	SUBFAMILY DP
	TYPES ${STM32_F7_DP_TYPES}
)

target_compile_options(STM32::F7::SP INTERFACE 
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m7>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv5-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
target_link_options(STM32::F7::SP INTERFACE 
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m7>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv5-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)

target_compile_options(STM32::F7::DP INTERFACE 
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m7>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv5-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
target_link_options(STM32::F7::DP INTERFACE 
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m7>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv5-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
