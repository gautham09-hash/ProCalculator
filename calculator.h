#ifndef CALCULATOR_H
#define CALCULATOR_H

#include <QObject>
#include <QString>
#include <vector>
#include <QVariantList>

class CalculatorBackend : public QObject {
    Q_OBJECT
public:
    explicit CalculatorBackend(QObject *parent = nullptr);

    Q_INVOKABLE QString calculateStandard(double currentTotal, double operand, QString op);
    Q_INVOKABLE QString calculateResistance(QString mode, QString valuesStr);
    Q_INVOKABLE QString calculateMesh(QVariantList rMatrix, QVariantList vVector);
    Q_INVOKABLE QString calculateVoltageDrop(QString r, QString i1, QString i2);
    Q_INVOKABLE QString calculateMatrix(QVariantList matA, QVariantList matB, int op);

private:
    std::vector<double> solveLinearSystem(std::vector<std::vector<double>> A, std::vector<double> B);
};

#endif
