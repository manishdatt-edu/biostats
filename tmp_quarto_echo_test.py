import json, os, subprocess
nb = {
  "cells": [{
    "cell_type": "code",
    "execution_count": None,
    "metadata": {},
    "outputs": [],
    "source": [
      "#| echo:false\n",
      "print(1)\n"
    ]
  }],
  "metadata": {"kernelspec": {"display_name": "R", "language": "R", "name": "ir"}, "language_info": {"name": "R"}},
  "nbformat": 4,
  "nbformat_minor": 5
}
p = os.path.join(os.getcwd(), 'tmp_quarto_echo_only.ipynb')
open(p, 'w', encoding='utf-8').write(json.dumps(nb))
print(p)
r = subprocess.run(['quarto', 'render', p, '--to', 'html', '--no-execute'], capture_output=True, text=True)
print(r.stdout)
print(r.stderr)
print('RC=', r.returncode)
