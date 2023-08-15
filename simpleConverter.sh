#!/usr/bin/env bash

definitionRegex='^[A-Za-z]+_to_[A-Za-z]+'
numberRegex='[0-9]+\.?[0-9]*$'
filename="data.txt"

isEmptyInput() {
  if [[ -z "$1" ]]; then
    echo "Enter a valid line number!"
    return 0
  else
    return 1
  fi
}

isZero() {
  if [ "$1" -eq 0 ]; then
      return 0
    else
      return 1
  fi
}

isNumberPassRegex() {
  if [[ $1 =~ $numberRegex ]]; then
    return 0
  else
    echo "Enter a valid line number!"
    return 1
  fi
}

isLineIsLessOrEqual() {
  if [[ "$1" -le "$(sed -n '$=' $filename)" ]]; then
    return 0
  else
    echo "Enter a valid line number!"
    return 1
  fi
}

addDefinition() {
  while true; do
    echo "Enter a definition:"
    read -a input
    if [[ ${#input[@]} == 2 && ${input[0]} =~ $definitionRegex && ${input[1]} =~ $numberRegex ]]; then
      printf "%s %s\n" "${input[0]}" "${input[1]}" >> "$filename";
      break
    else
      echo "The definition is incorrect!"
    fi
  done

}

deleteDefinition() {
  if [[ -s "$filename" ]]; then

    printf "Type the line number to delete or '0' to return\n" && nl -w1 -s". " "$filename"

    while true ; do
      read lineToDelete
      if isEmptyInput "$lineToDelete" ; then
        continue
      elif isZero "$lineToDelete" ; then
        break
      elif ! (isNumberPassRegex "$lineToDelete") ; then
        continue
      elif ! (isLineIsLessOrEqual "$lineToDelete") ; then
        continue
      else
        # sed -i  "" "${lineToDelete}d" "$filename" # -- works on Macos and does not work on Code Editor
        sed -i "${lineToDelete}d" "$filename" # -- works on Code Editor and does not work on Macos
        break
      fi
    done

  else
    echo "Please add a definition first!"
  fi
}

convertUnits() {
  if [[ -s "$filename" ]]; then
    printf "Type the line number to convert units or '0' to return\n" && nl -w1 -s". " "$filename"

    while true ; do
      read lineToConvert
      if isEmptyInput "$lineToConvert" ; then
        continue
      elif isZero "$lineToConvert" ; then
        break
      elif ! (isNumberPassRegex "$lineToConvert") ; then
        continue
      elif ! (isLineIsLessOrEqual "$lineToConvert") ; then
        continue
      else # success case
        echo "Enter a value to convert: "
        while true; do
           read valueToConvert
           if [[ $valueToConvert =~ $numberRegex ]]; then
             x=$(sed "${lineToConvert}!d" "$filename" | cut -d " " -f 2)
             echo "Result: $(bc -l <<< "$x * $valueToConvert")"
             break
           else
             echo "Enter a float or integer value!"
             continue
           fi
        done
        break
      fi
    done

  else
    echo "Please add a definition first!"
  fi
}

echo "Welcome to the Simple converter!"

while true; do
    printf "Select an option\n0. Type '0' or 'quit' to end program\n1. Convert units\n2. Add a definition\n3. Delete a definition\n"

    read -r option

    case $option in
      0 | 'quit')
        echo "Goodbye!"
        break;;
      1)
        convertUnits;;
      2)
        addDefinition;;
      3)
        deleteDefinition;;
      *)
        echo "Invalid option!";;
    esac
done
