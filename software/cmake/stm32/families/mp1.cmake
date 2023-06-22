set(STM32_MP1_TYPES 
	# STM32MP151
	MP151Axx MP151Cxx MP151Dxx MP151Fxx
	# STM32MP153
	MP153Axx MP153Cxx MP153Dxx MP153Fxx
	# STM32MP157
	MP157Axx MP157Cxx MP157Dxx MP157Fxx
)

_stm32_create_family_targets(
	FAMILY MP1
	SUBFAMILY M4
	TYPES ${STM32_MP1_TYPES}
)

target_compile_options(STM32::MP1::M4 INTERFACE
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m4>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv4-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
target_link_options(STM32::MP1::M4 INTERFACE
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m4>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv4-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
target_compile_definitions(STM32::MP1::M4 INTERFACE
	CORE_CM4
)
