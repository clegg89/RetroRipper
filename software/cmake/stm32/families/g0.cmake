_stm32_create_family_targets(FAMILY G0)

target_compile_options(STM32::G0 INTERFACE 
    $<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m0plus>
)
target_link_options(STM32::G0 INTERFACE 
    $<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m0plus>
)
