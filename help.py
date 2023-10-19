class Help:

    @staticmethod
    def append(*parts):

        output = ''

        for part in parts:
            output += str(part)

        return output