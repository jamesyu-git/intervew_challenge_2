from decimal import Decimal

def format_number_with_commas(number):
    try:
        formatted_number = "{:,}".format(Decimal(str(number)))
        return formatted_number
    except Exception as e:
        return f"Error: {str(e)}"