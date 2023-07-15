_stm32_create_family_targets(FAMILY L0)

target_compile_options(STM32::L0 INTERFACE 
    $<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m0plus>
)
target_link_options(STM32::L0 INTERFACE 
    $<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m0plus>
)
