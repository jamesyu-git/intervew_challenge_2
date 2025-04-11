from decimal import Decimal

def convert_fee(fee):
    print(f"💡 DEBUG: Received fee -> Type: {type(fee)}, Value: {fee}")

    try:
        fee = float(fee)
        print("translate")
        return float(Decimal(str(fee)) * 100)
    except (ValueError, TypeError, ArithmeticError) as e:
        return f"ERROR: {str(e)}"