// PreCompCNoise.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#define _USE_MATH_DEFINES // for C++
#include <cmath>

#include <iostream>
#include <fstream>
#include <iomanip>

using namespace std;

struct Vector3r
{
	double x, y, z;

	Vector3r( double X, double Y, double Z )
	: x( X )
	, y( Y )
	, z( Z )
	{}
};

Vector3r anglesToVec( double theta, double phi, double radius )
{
	const double r_sin_phi = radius * sin( phi );

	return Vector3r(
		r_sin_phi * cos( theta ),
		r_sin_phi * sin( theta ),
		radius * cos( phi ) );
}


int main()
{
    std::cout << "Writing precomputed!\n";

	size_t N = 4096;


	ofstream file( "randomC.hpp" );
	ofstream fileV( "randomCV.hpp" );
	
	file << "#ifndef RANDOMC_HPP" << endl;
	file << "#define RANDOMC_HPP" << endl;
	file << endl << "#include <vector>" << endl << endl;
	file << "std::vector<double> randomC = { ";

	fileV << "#ifndef RANDOMCV_HPP" << endl;
	fileV << "#define RANDOMCV_HPP" << endl;
	fileV << endl << "#include <vector>" << endl << endl;
	fileV << "std::vector<double> randomCV = { ";

	for( int i = 0; i < N; i++ )
	{
		const double a = rand() / double( RAND_MAX );
		const double b = rand() / double( RAND_MAX );

		double theta = 2.0 * M_PI * a;
		double phi = acos( 1.0 - 2.0 * b );

		Vector3r v = anglesToVec( theta, phi, 1.0 );

		file  << setprecision( 15 ) << a << ", " << b;
		fileV << setprecision( 15 ) << v.x << ", " << v.y << ", " << v.z;

		if( i < N - 1 )
		{
			file  << ", ";
			fileV << ", ";
		}

		if( (i + 1) % 10 == 0 )
		{
			file << endl << "    ";
			fileV << endl << "    ";
		}
	}

	file << "};" << endl;
	file << "#endif" << endl;

	fileV << "};" << endl;
	fileV << "#endif" << endl;

	file.close();
	fileV.close();
}
