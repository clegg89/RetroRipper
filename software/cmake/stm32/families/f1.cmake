set(STM32_F1_COMPILE_OPTIONS
    $<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m3>
)

set(STM32_F1_LINK_OPTIONS
    $<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m3>
)
