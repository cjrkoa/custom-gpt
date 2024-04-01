def read_raw(filename: str) -> str:
    file = open(filename, "r")

    output = ""

    for line in file.readlines():
        output += line

    return output

def read(filename: str) -> str:
    file = open(filename, "r")

    output = ""
    remove = ["#figure", "table(", ")", "[", "]", "#req", "=", "<Section::", ">"]

    for line in file.readlines():
        for item in remove:
            if item in line:
                line = line.replace(item, "")
        output += line

    return output

def read_files(filenames: list) -> list:
    output = []

    for filename in filenames:
        output.append(read(filename))

    return output

def generate_openai_api_messages(content_list: list) -> list:
    output = []

    for item in content_list:
        message = {"role": "system", "content": item}
        output.append(message)

    return output

if __name__ == "__main__":
    print(read_files(["balancer-requirements.typ", "balancer-design.typ"]))