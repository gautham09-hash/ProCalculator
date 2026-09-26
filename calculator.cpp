#include "calculator.h"
#include <QStringList>
#include <cmath>
#include <QVariantList>

CalculatorBackend::CalculatorBackend(QObject *parent) : QObject(parent) {}

QString CalculatorBackend::calculateStandard(double currentTotal, double operand, QString op) {
    double res = currentTotal;
    if (op == "+") res += operand;
    else if (op == "-") res -= operand;
    else if (op == "*") res *= operand;
    else if (op == "/") {
        if (operand != 0.0) res /= operand;
        else return "Error";
    } else {
        res = operand;
    }
    return QString::number(res);
}

QString CalculatorBackend::calculateResistance(QString mode, QString valuesStr) {
    QStringList strValues = valuesStr.split(',');
    QList<double> resistors;
    for (const QString &str : strValues) {
        bool ok; double val = str.trimmed().toDouble(&ok);
        if (ok) resistors.append(val);
    }
    if (resistors.isEmpty()) return "Error: Invalid inputs";
    
    double req = 0.0;
    if (mode == "Parallel") {
        double rSum = 0.0;
        for (double r : resistors) { 
            if (r <= 0) return "Req: 0 Ω (Short)"; 
            rSum += (1.0 / r); 
        }
        req = 1.0 / rSum;
    } else { 
        for (double r : resistors) req += r; 
    }
    return QString("Req: %1 Ω").arg(req, 0, 'f', 2);
}

std::vector<double> CalculatorBackend::solveLinearSystem(std::vector<std::vector<double>> A, std::vector<double> B) {
    int n = B.size();
    for (int i = 0; i < n; i++) {
        int maxRow = i; 
        for (int k = i + 1; k < n; k++) { if (std::abs(A[k][i]) > std::abs(A[maxRow][i])) maxRow = k; }
        std::swap(A[i], A[maxRow]); std::swap(B[i], B[maxRow]);
        if (std::abs(A[i][i]) < 1e-9) return {}; 
        for (int k = i + 1; k < n; k++) { 
            double factor = A[k][i] / A[i][i];
            for (int j = i; j < n; j++) A[k][j] -= factor * A[i][j];
            B[k] -= factor * B[i];
        }
    }
    std::vector<double> x(n, 0); 
    for (int i = n - 1; i >= 0; i--) {
        double sum = 0;
        for (int j = i + 1; j < n; j++) sum += A[i][j] * x[j];
        x[i] = (B[i] - sum) / A[i][i];
    }
    return x;
}

QString CalculatorBackend::calculateMesh(QVariantList rMatrix, QVariantList vVector) {
    std::vector<std::vector<double>> R(3, std::vector<double>(3, 0.0));
    std::vector<double> V(3, 0.0);
    
    for (int i = 0; i < 3; ++i) {
        V[i] = vVector[i].toDouble();
        QVariantList row = rMatrix[i].toList();
        for (int j = 0; j < 3; ++j) {
            R[i][j] = row[j].toDouble();
        }
    }

    std::vector<double> currents = solveLinearSystem(R, V);
    if(currents.empty()) return "Error: Matrix is unsolvable.";
    
    return QString("I₁ = %1 A\nI₂ = %2 A\nI₃ = %3 A")
        .arg(currents[0], 0, 'f', 3)
        .arg(currents[1], 0, 'f', 3)
        .arg(currents[2], 0, 'f', 3);
}

QString CalculatorBackend::calculateVoltageDrop(QString r, QString i1, QString i2) {
    double res = r.toDouble();
    double cur1 = i1.toDouble();
    double cur2 = i2.isEmpty() ? 0.0 : i2.toDouble();
    double vDrop = res * std::abs(cur1 - cur2);
    return QString("Voltage Drop = %1 V").arg(vDrop, 0, 'f', 3);
}

QString CalculatorBackend::calculateMatrix(QVariantList matA, QVariantList matB, int op) {
    std::vector<std::vector<double>> A(3, std::vector<double>(3, 0.0));
    std::vector<std::vector<double>> B(3, std::vector<double>(3, 0.0));

    for (int i = 0; i < 3; ++i) {
        QVariantList rowA = matA[i].toList();
        QVariantList rowB = matB[i].toList();
        for (int j = 0; j < 3; ++j) {
            A[i][j] = rowA[j].toDouble();
            B[i][j] = rowB[j].toDouble();
        }
    }

    if (op < 3) {
        QString out = "Result Matrix:\n";
        for (size_t i = 0; i < 3; i++) {
            out += "[ ";
            for (size_t j = 0; j < 3; j++) {
                double val = 0;
                if (op == 0) val = A[i][j] + B[i][j];
                else if (op == 1) val = A[i][j] - B[i][j];
                else if (op == 2) {
                    for (size_t k = 0; k < 3; k++) val += A[i][k] * B[k][j];
                }
                out += QString::number(val, 'f', 2) + "  ";
            }
            out += "]\n";
        }
        return out;
    } else {
        std::vector<std::vector<double>> target = (op == 3) ? A : B;
        double det = target[0][0] * (target[1][1] * target[2][2] - target[1][2] * target[2][1])
                   - target[0][1] * (target[1][0] * target[2][2] - target[1][2] * target[2][0])
                   + target[0][2] * (target[1][0] * target[2][1] - target[1][1] * target[2][0]);
        return QString("Determinant = %1").arg(det, 0, 'f', 4);
    }
}
