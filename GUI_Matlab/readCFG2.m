function [coord,aType,Mm,DW,occ,charge] = readCFG( filename )

    % Robert A. McLeod
    % 14 April 2014
    % This is designed to replace readCFG_qstem, which likes to break.

    %% Open file
    location = regexp( filename, '\.cfg', 'ONCE' );
    if( isempty(location) )
        filename_ext = [filename, '.cfg' ];
    else
        filename_ext = filename;
    end
    disp( ['Attempting to open : ', filename_ext ] )
    fHand= fopen( filename_ext, 'r' );

    if( fHand == -1 )
        error( [ 'Error, ', filename_ext', ' not found.' ] )
    end

    %% Parse .CFG header
    % first line, number of atoms
    buffer = fgetl( fHand );
    nAtom = str2double( buffer( regexp( buffer, '\d' ) ) );

    % second line, length scale (ignored)
    fgetl( fHand );

    % 3rd-11th lines, the Mm matrix
    Mm = zeros( [3 3] );
    for J = 1:9
        buffer = fgetl( fHand );

        [startM, endM] = regexp( buffer, '[-+]?\d*\.?\d*', 'start', 'end' );
        % We are only interested in the last match, the actual number (and not
        % the matrix indices
        Mm(J) = str2double( buffer( startM(end):endM(end) )  );
    end

    fgetl( fHand ); % No velocity
    fgetl( fHand ); % Nummber of atom types (wrong, do not use)

    %% End of .CFG header, start of body
    % Preallocate
    coord = zeros( [nAtom 3] );
    aType = zeros( [nAtom 1] );
    DW = zeros( [nAtom 1] );
    occ = zeros( [nAtom 1] );
    charge = zeros( [nAtom 1] );

    % Try to scan a single number (Z*2) followed by a end-of-line, followed
    % by a character
    atomZ = textscan( fHand, '%d' );
    atomZ = atomZ{1}/2;
    % Check for break
    %     if( isempty( newAtom ) || isnan(newAtom) )
    %         break;
    %     end
    fgetl( fHand ); % next line, string, discard
    atomIndex = 1;
    
    while( atomIndex <= nAtom )
        
        % Read a line and get the number of parameters
        buffer = fgets(fHand);
        Params = str2num(buffer);
        numParams = length(Params);
       
        if(numParams <=0)
            break;
        end
        
        if(numParams == 6)
            aType(atomIndex) = atomZ;
            coord(atomIndex,1:3) = Params(1:3);
            DW(atomIndex) = Params(4);
            occ(atomIndex) = Params(5);
            charge(atomIndex) = Params(6);
            atomIndex = atomIndex + 1;
        elseif(numParams == 5)
            aType(atomIndex) = atomZ;
            coord(atomIndex,1:3) = Params(1:3);
            DW(atomIndex) = Params(4);
            occ(atomIndex) = Params(5);
            atomIndex = atomIndex + 1;
        elseif(numParams == 4)
            aType(atomIndex) = atomZ;
            coord(atomIndex,1:3) = Params(1:3);
            DW(atomIndex) = Params(4);
            atomIndex = atomIndex + 1;
        elseif(numParams == 3)
            aType(atomIndex) = atomZ;
            coord(atomIndex,1:3) = Params(1:3);
            atomIndex = atomIndex + 1;
        else
            atomZ = Params(1)/2;
            fgets(fHand);
        end
       
    end

    fclose( fHand );
end