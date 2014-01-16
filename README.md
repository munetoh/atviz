atviz
=====

simple attack tree[1] visualization tool.


----
## Install

Gemfile

    gem 'atviz', github: "munetoh/atviz"


----
## Usage

    atviz input_json  output_pdf


----
## JSON format

    key          value
    ----------------------------------------------------------------
    tree         hash tree is attack tree
    flat_tree    flat hash list with chiled of attribute
    type         Select node type: threat, attack, countermeasure
    description  Description of the node
    and          List children w/ and
    or           List children w/ or
    chilrd_of    parent node 



----
## Graphviz default shapes

    shape      description
    ---------------------------------
    invhouse   top threat
    ellipse    AND nodes
    diamond    OR nodes
    box        countermeasure
    house      countermeasure (sink)


This AND/OR node shapes are the style of MulVAL[2].

----
## References

  1. http://en.wikipedia.org/wiki/Attack_tree
  2. http://www.arguslab.org/mulval.html
