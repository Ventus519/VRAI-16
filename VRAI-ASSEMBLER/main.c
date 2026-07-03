#include <stdio.h>
#include "field_definitions_vrai.h"
#include "Assembler.h"
static const int MAX_SYMBOLS = 65536/4;




int main(int argc, char** argv)
{
    if (argc != 3 || !argv || !argv[0] || !argv[1] || !argv[2])
    {
        printf("Incorrect number of arguments. Refer to the following way indicating how to include arguments:\n");
        printf("./VRAIa <destination file> <source assembly>\n");
        printf("Number of arguments received: %d\n\n", argc);
        return EXIT_FAILURE;
    }

    pre_processing(argv[2], "./program.vrai_preproc");

    Program* PROGRAM = create_program();

    if (!PROGRAM)
    {
        return EXIT_FAILURE;
    }

    if (parse_file("./program.vrai_preproc", argv[1], PROGRAM))
    {
        free(PROGRAM);
        return EXIT_FAILURE;
    }

    printf("\n");

    for (int i = 0; i < PROGRAM -> INSTRUCTION_COUNT; i++)
    {
        print_instruction(&PROGRAM -> INSTRUCTS[i]);
        printf("\n");
    }

    free(PROGRAM);
    return EXIT_SUCCESS;
}
