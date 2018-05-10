import click

from pre_process import pre_process


@click.group()
def cli():
    pass


@click.command()
@click.argument('input', type=click.File('r'))
def preprocessing(input):
    metabolites = int(input.readline())
    reactions = int(input.readline())
    print('Metabolites: {0}\nReactions: {1}\n'.format(metabolites, reactions))

    reversibles = [int(x) for x in input.readline().split()]

    stoichio = []
    for line in input:
        stoichio.append([float(x) for x in line.split()])

    pre_process(stoichio, reversibles)


@click.command()
def postprocessing():
    pass


if __name__ == '__main__':
    cli.add_command(preprocessing)
    cli.add_command(postprocessing)
    cli()
